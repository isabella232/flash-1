package com.pubnub.subscribe {
import com.pubnub.*;
import com.pubnub.connection.*;
import com.pubnub.environment.*;
import com.pubnub.json.*;
import com.pubnub.log.Log;
import com.pubnub.operation.*;

import flash.events.*;
import flash.utils.*;

import org.casalib.util.*;

use namespace pn_internal;

/**
 * ...
 * @author firsoff maxim, support@pubnub.com
 */
public class Subscribe extends EventDispatcher {

    static public const PNPRES_PREFIX:String = '-pnpres';
    static public const SUBSCRIBE:String = 'subscribe';
    static public const INIT_SUBSCRIBE:String = 'init_subscribe';
    static public const LEAVE:String = 'leave';

    public var subscribeKey:String;
    public var sessionUUID:String;
    public var cipherKey:String;

    protected var _origin:String = "";
    protected var _connected:Boolean;

    protected var _retryMode:Boolean = false;
    protected var _subscribeDelay:int = 0;
    protected var _retryCount:int = 0;

    protected var _connectionUID:String;
    protected var _lastToken:String;
    protected var _existingTimeToken:String;
    protected var factory:Dictionary;
    protected var _destroyed:Boolean;
    protected var _channels:Array;
    protected var savedChannels:Array;
    protected var savedTimetoken:String;

    protected var asyncConnection:AsyncConnection;
    protected var _networkEnabled:Boolean;


    public function Subscribe() {
        super(null);
        init();
    }

    protected function init():void {
        _channels = [];
        factory = new Dictionary();
        factory[INIT_SUBSCRIBE] = getSubscribeInitOperation;
        factory[SUBSCRIBE] = getSubscribeOperation;
        factory[LEAVE] = getLeaveOperation;

        asyncConnection = new AsyncConnection();
        asyncConnection.addEventListener(OperationEvent.TIMEOUT, onTimeout);
    }

    private function onTimeout(e:OperationEvent):void {
        dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ 0, Errors.NETWORK_UNAVAILABLE]));
        dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_DISABLE_VIA_SUBSCRIBE_TIMEOUT));
    }

    public function subscribe(channelList:String, existingTimeToken:String = null):Boolean {

        var channelString:String;
        var channelsToAdd:Array = [];

        if (!isNetworkEnabled()) {
            dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ 0, Errors.NETWORK_UNAVAILABLE]));
            return false;
        }

        if (!isChannelListValid(channelList)) {
            dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ 0, Errors.SUBSCRIBE_CHANNEL_TOO_BIG_OR_NULL, channels]));
            return false;
        }

        if (existingTimeToken) {
            _existingTimeToken = existingTimeToken;
        }

        var channelListAsArray:Array = channelList.split(',');
        for (var i:int = 0; i < channelListAsArray.length; i++) {
            channelString = StringUtil.removeWhitespace(channelListAsArray[i]);
            if (channelIsInChannelList(channelString)) {
                dispatchEvent(new SubscribeEvent(SubscribeEvent.WARNING, [ 0, Errors.SUBSCRIBE_ALREADY_SUBSCRIBED, channelString]));
            } else {
                channelsToAdd.push(channelString);
            }
        }
        processNewActiveChannelList(channelsToAdd);
        return channelsToAdd.length > 0;
    }

    public function unsubscribe(channelList:String, reason:Object = null):Boolean {
        if (!isNetworkEnabled()) {
            dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ 0, Errors.NETWORK_UNAVAILABLE]));
            return false;
        }

        if (!isChannelListValid(channelList)) {
            dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ 0, Errors.SUBSCRIBE_CHANNEL_TOO_BIG_OR_NULL, channels]));
            return false;
        }

        var channelsToRemove:Array = [];
        var channelListAsArray:Array = channelList.split(',');
        var channelString:String;
        for (var i:int = 0; i < channelListAsArray.length; i++) {
            channelString = StringUtil.removeWhitespace(channelListAsArray[i]);
            if (channelIsInChannelList(channelString)) {
                channelsToRemove.push(channelString);
            } else {
                dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ -1, Errors.NOT_CONNECTED, channelString]));
            }
        }
        processNewActiveChannelList(null, channelsToRemove, reason);
        return channelsToRemove.length > 0;
    }

    public function unsubscribeAll(reason:Object = null):void {
        if (!isNetworkEnabled()) {
            dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ 0, Errors.NETWORK_UNAVAILABLE]));
            return;
        }

        doUnsubscribeAll(reason);
    }

    private function doUnsubscribeAll(reason:Object = null):void {
        //clearInterval(resubTimer);
        var allChannels:String = _channels.join(',');
        unsubscribe(allChannels, reason);
    }

    private function isChannelListValid(channel:String):Boolean {
        if (channel == null || channel.length > int.MAX_VALUE || _destroyed) {
            return false;
        }
        return true;
    }

    private function isNetworkEnabled():Boolean {
        return _networkEnabled;
    }


    private function processNewActiveChannelList(addCh:Array = null, removeCh:Array = null, reason:Object = null):void {
        var needAdd:Boolean = addCh && addCh.length > 0;
        var needRemove:Boolean = removeCh && removeCh.length > 0;
        if (needAdd || needRemove) {
            asyncConnection.close();
            if (needRemove) {
                var removeChStr:String = removeCh.join(',');
                leave(removeChStr);
                ArrayUtil.removeItems(_channels, removeCh);
                dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, { channel: removeChStr, reason: (reason ? reason : '') }));
            }

            if (needAdd) {
                _channels = _channels.concat(addCh);
            }

            //trace('_lastToken : ' + _lastToken);
            if (_channels.length > 0) {
                if (_lastToken) {
                    doSubscribe();
                } else {
                    subscribeInit();
                }
            } else {
                _lastToken = null;
            }
        }
    }


    /*---------------------------INIT---------------------------*/
    protected function subscribeInit():void {
        //trace('subscribeInit : ' + sessionUUID, _channels);
        _connectionUID = PnUtils.getUID();
        var operation:Operation = getOperation(INIT_SUBSCRIBE);
        asyncConnection.sendOperation(operation);
    }

    protected function onSubscribeInit(e:OperationEvent):void {
        if (_networkEnabled == false) return;

        if (e.data == null) {
            subscribeInit();
            return;
        }
        _connected = true;
        _lastToken = e.data[1];
        //trace('onSubscribeInit : ' + _lastToken);
        if (_existingTimeToken) {
            _lastToken = _existingTimeToken;
            _existingTimeToken = null;
        }


        dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT, { channel: _channels.join(',') }));
        destroyOperation(e.target as Operation);
        doSubscribe();
    }

    protected function onSubscribeInitError(e:OperationEvent):void {
        dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ -1, Errors.SUBSCRIBE_INIT_ERROR]));
        destroyOperation(e.target as Operation);
    }

    /*---------------------------SUBSCRIBE---------------------------*/
    private function doSubscribe():void {
        var operation:Operation = getOperation(SUBSCRIBE);
        asyncConnection.sendOperation(operation);
    }

    protected function onMessageReceived(e:OperationEvent):void {

        if (_networkEnabled == false) return;

        var RESPONSE:Object = e.data;

        //Log.log('RESPONSE : '
        // something is wrong
        if (RESPONSE == null) {
            Log.log("SubConnect: notOK: is null. TT: " + _lastToken, Log.DEBUG);
            doSubscribe();
            return;
        }

        try {
            var messages:Array = RESPONSE[0] as Array;
            _lastToken = RESPONSE[1];
            var chStr:String = RESPONSE[2];
        } catch (e) {
            Log.log("SubConnect: notOK: broken response: " + e + " , TT: " + _lastToken, Log.DEBUG);
            doSubscribe();
        }

        /*
         * MX (array.length = 3)
         * RESPONSE = [['m1', 'm2', 'm3', 'm4'], lastToken, ['ch1', 'ch2', 'ch2', 'ch3']];
         *
         * ch1 - m1
         * ch2 - m2,m3
         * ch3 - m4
         *
         * Single channel RESPONSE (array.length = 2)
         * RESPONSE = [['m1', 'm2', 'm3', 'm4'], lastToken];
         */

        retryCount = 0;

        var multiplexRESPONSE:Boolean = chStr && chStr.length > 0 && chStr.indexOf(',') > -1;
        var presenceRESPONSE:Boolean = chStr && chStr.indexOf(PNPRES_PREFIX) > -1;
        var channel:String;

        if (presenceRESPONSE) {
            dispatchEvent(new SubscribeEvent(SubscribeEvent.PRESENCE, {channel: chStr, message: messages, timetoken: _lastToken}));
        } else {
            if (!messages) return;
            decryptMessages(messages);

            if (multiplexRESPONSE) {
                var chArray:Array = chStr.split(',');
                for (var i:int = 0; i < messages.length; i++) {
                    channel = chArray[i];
                    if (channelIsInChannelList(channel)) {
                        dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, {
                            channel: channel,
                            message: messages[i],
                            timetoken: _lastToken }));
                    }
                }
            } else {
                channel = chStr || _channels[0];
                for (var j:int = 0; j < messages.length; j++) {
                    dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, {
                        channel: channel,
                        message: messages[j],
                        timetoken: _lastToken }));
                }
            }
        }
        //Log.log("SubConnect: ok, TT: " + _lastToken);
        doSubscribe();
    }

    private function decryptMessages(messages:Array):void {
        if (messages) {
            for (var i:int = 0; i < messages.length; i++) {
                var msg:* = cipherKey.length > 0 ? PnJSON.parse(PnCrypto.decrypt(cipherKey, messages[i])) : messages[i];
                messages[i] = msg;
            }
        }
    }

    protected function onConnectError(e:OperationEvent):void {
        //trace('onSubscribeError!');
        dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ -1, Errors.SUBSCRIBE_CHANNEL_ERROR]));
        destroyOperation(e.target as Operation);
    }

    /*---------------------------LEAVE---------------------------------*/
    protected function leave(channel:String):void {
        var operation:Operation = getOperation(LEAVE, channel);
        Pn.pn_internal::syncConnection.sendOperation(operation);
    }

    protected function getOperation(type:String, ...rest):Operation {
        return factory[type].apply(null, rest);
    }

    protected function destroyOperation(op:Operation):void {
        op.destroy();
    }

    protected function getSubscribeInitOperation(args:Object = null):Operation {
        var operation:SubscribeInitOperation = new SubscribeInitOperation(origin);
        operation.setURL(null, {
            channel: this.channelsString,
            subscribeKey: subscribeKey,
            uid: sessionUUID});
        operation.addEventListener(OperationEvent.RESULT, onSubscribeInit);
        operation.addEventListener(OperationEvent.FAULT, onSubscribeInitError);
        return operation;
    }

    protected function getSubscribeOperation():Operation {
        var operation:SubscribeOperation = new SubscribeOperation(origin);
        operation.setURL(null, {
            timetoken: _lastToken,
            subscribeKey: subscribeKey,
            channel: this.channelsString,
            uid: sessionUUID});
        operation.addEventListener(OperationEvent.RESULT, onMessageReceived);
        operation.addEventListener(OperationEvent.FAULT, onConnectError);
        return operation;
    }

    protected function getLeaveOperation(channel:String):Operation {
        var operation:LeaveOperation = new LeaveOperation(origin);
        operation.setURL(null, {
            channel: channel,
            uid: sessionUUID,
            subscribeKey: subscribeKey
        });
        return operation;
    }

    public function get connected():Boolean {
        return _connected;
    }

    public function get origin():String {
        return _origin;
    }

    public function set origin(value:String):void {
        _origin = value;
    }

    public function get connectionUID():String {
        return _connectionUID;
    }

    public function set connectionUID(value:String):void {
        _connectionUID = value;
    }

    public function get destroyed():Boolean {
        return _destroyed;
    }

    public function destroy():void {
        if (_destroyed) return;
        _destroyed = true;
        close();
        asyncConnection.removeEventListener(OperationEvent.TIMEOUT, onTimeout);
        asyncConnection.destroy();
        asyncConnection = null;
    }

    public function close(reason:String = null):void {
        doUnsubscribeAll(reason);
        asyncConnection.close();
        if (_channels.length > 0) {
            leave(_channels.join(','));
        }
        _channels.length = 0;
        _connected = false;
        _lastToken = null;
    }

    protected function get channelsString():String {
        var result:String = '';
        var len:int = _channels.length;
        var comma:String = ',';
        for (var i:int = 0; i < len; i++) {
            if (i == (len - 1)) {
                result += _channels[i]
            } else {
                result += _channels[i] + comma;
            }
        }
        return result;
    }

    public function get channels():Array {
        return _channels;
    }

    public function set networkEnabled(value:Boolean):void {
        _networkEnabled = value;

        asyncConnection.networkEnabled = value;

        trace("NW_ENABLED = " + value)


        if (value == true) {

            if (Settings.RESUME_ON_RECONNECT) {
                var token:String = savedTimetoken;
            }
            if (savedChannels && savedChannels.length > 0) {
                subscribe(savedChannels.join(','), token);
            }
            savedTimetoken = null;
            savedChannels = [];
        } else if (value == false) {

            savedTimetoken = _lastToken;
            savedChannels = _channels.concat();
            close('Close with network unavailable');
        }
    }

    public function get retryCount():int {
        return _retryCount;
    }

    public function set retryCount(value:int):void {
        _retryCount = value;
    }

    public function get retryMode():Boolean {
        return _retryMode;
    }

    public function set retryMode(value:Boolean):void {
        _retryMode = value;
    }

    public function set subscribeDelay(value:int):void {
        _subscribeDelay = value;
    }

    public function get networkEnabled():Boolean {
        return _networkEnabled;
    }

    public function get lastToken():String {
        return _lastToken;
    }

    private function channelIsInChannelList(ch:String):Boolean {
        return (ch != null && _channels.indexOf(ch) > -1);
    }
}
}