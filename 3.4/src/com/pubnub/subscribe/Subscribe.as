package com.pubnub.subscribe {
import com.pubnub.*;
import com.pubnub.connection.*;
import com.pubnub.environment.*;
import com.pubnub.json.*;
import com.pubnub.log.Log;
import com.pubnub.operation.*;

import flash.events.*;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import org.casalib.util.*;

use namespace pn_internal;


public class Subscribe extends EventDispatcher {

    static public const PNPRES_PREFIX:String = '-pnpres';
    static public const SUBSCRIBE:String = 'subscribe';

    public var subscribeKey:String;
    public var cipherKey:String;
    public var secretKey:String;

    protected var _origin:String = "";
    protected var _retryCount:int = 0;
    protected var retryInterval:int = 0;
    protected var _UUID:String = null;
    protected var _lastReceivedTimetoken:String = "0";
    protected var _savedTimetoken:String = "0";
    protected var _destroyed:Boolean;
    protected var _channels:Array;
    protected var subscribeConnection:SubscribeConnection;
    protected var _networkEnabled:Boolean = false;


    public function Subscribe(origin) {
        super(null);
        _origin = origin;
        init();
    }

    protected function init():void {
        _channels = [];

        subscribeConnection = new SubscribeConnection();
        addEventListener(OperationEvent.TIMEOUT, onError);
        subscribeConnection.addEventListener(OperationEvent.CONNECT, onConnect);
        subscribeConnection.addEventListener(OperationEvent.TIMEOUT, onError);
        subscribeConnection.addEventListener(OperationEvent.CONNECTION_ERROR, onError);
    }

    protected function onConnect(e:OperationEvent):void {
        Log.log("Subscribe: onConnect", Log.DEBUG);

        if (Settings.PANIC_ON_SILENCE == false) {
            dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT, [1, "silence has been broken" ]));
            dispatchEvent(new NetMonEvent(NetMonEvent.SUB_NET_UP))
        }

    }

    public function onError(e:OperationEvent):void {
        trace("Subscribe.onError")
        retryToConnect(new NetMonEvent(NetMonEvent.SUB_NET_DOWN));
    }

    private function onNetworkEnable():void {
        trace("Sub.onNetworkEnable: Re-enabling network now!");

        clearInterval(retryInterval);
        retryInterval = 0;

        networkEnabled = true;
    }

    public function retryToConnect(e:NetMonEvent):void {

        // if there is already a timer running, return.
        if (retryInterval > 0) {
            return;
        }

        trace("Subscribe.delayedOnNetworkDisable: " + Settings.RECONNECT_RETRY_DELAY);
        retryInterval = setInterval(onNetworkDisable, Settings.RECONNECT_RETRY_DELAY);
    }

    public function onNetworkDisable():void {

        if (Settings.PANIC_ON_SILENCE == true && networkEnabled) {
            dispatchEvent(new NetMonEvent(NetMonEvent.SUB_NET_DOWN));
            dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, [0, "disconnect due to silence"]));
        }

        subscribeConnection.close();
        trace("Sub.onNetworkDisable");

        if (Settings.PANIC_ON_SILENCE == true) {
            retryCount++;
        }

        networkEnabled = false;

        tryToConnect();
    }

    private function tryToConnect():void {

        if (networkEnabled) {
            return;
        }

        trace("tryToConnect CALLED");
        Log.log("Sub.tryToConnect: " + retryCount + " / " + Settings.MAX_RECONNECT_RETRIES, Log.DEBUG, new SubscribeOperation("1"))

        if (channels && channels.length > 0) {

            if (Settings.PANIC_ON_SILENCE == true) {

                if (retryCount < Settings.MAX_RECONNECT_RETRIES && channels && channels.length > 0) {
                    trace("Sub.tryToConnect not yet at max retries. retrying.");
                    executeSubscribeOperation();

                } else {
                    trace("Sub.tryToConnect reached MAX_RETRIES!");
                    unsubscribeAll();
                }

            } else {
                // if PANIC_ON_SILENCE is not true, then we will try to re-sub infinately
                executeSubscribeOperation();

            }
        }

    }

    public function subscribe(channelList:String, useThisTimeokenInstead:String = null):Boolean {
        trace("Sub.subscribe");

        if (useThisTimeokenInstead) {
            savedTimetoken = useThisTimeokenInstead;
            lastReceivedTimetoken = useThisTimeokenInstead;
        }
        trace("Sub.subscribe " + channelList.toString());
        return validateNewChannelList("subscribe", channelList).length > 0;
    }

    public function unsubscribe(channelList:String, reason:Object = null):Boolean {
        var channelsToModify:Array = validateNewChannelList("unsubscribe", channelList, reason);
        return channelsToModify.length > 0;
    }

    protected function validateNewChannelList(operationType:String, channelList:String, reason:Object = null):Array {
        trace("Sub.validateNewChannelList: " + operationType);

        if (!isChannelListValid(channelList)) {
            trace("validateNewChannelList: not a valid channellist, so returning a blank array");
            dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ 0, Errors.SUBSCRIBE_CHANNEL_TOO_BIG_OR_NULL, channels]));
            return [];
        }

        var channelsToModify:Array = [];
        var channelListAsArray:Array = channelList.split(',');
        var channelString:String;

        for (var i:int = 0; i < channelListAsArray.length; i++) {
            channelString = StringUtil.removeWhitespace(channelListAsArray[i]);

            if (operationType == "subscribe") {
                if (channelIsInChannelList(channelString)) {
                    dispatchEvent(new SubscribeEvent(SubscribeEvent.WARNING, [ 0, Errors.SUBSCRIBE_ALREADY_SUBSCRIBED, channelString]));
                } else {
                    channelsToModify.push(channelString);
                }
            }
            if (operationType == "unsubscribe") {
                if (channelIsInChannelList(channelString)) {
                    channelsToModify.push(channelString);
                } else {
                    dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ 0, Errors.SUBSCRIBE_CANT_UNSUB_NON_SUB, channelString]));
                }
            }
        }

        trace("validateNewChannelList: activateNewChannelList with " +
                channelsToModify.toString() + " " + operationType);

        activateNewChannelList(channelsToModify, operationType);

        return channelsToModify;
    }


    private function activateNewChannelList(newChannelList:Array, operationType:String):void {

        trace("Sub.activateNewChannelList");

        subscribeConnection.close();

        if (operationType == "unsubscribe") {
            var removeChStr:String = newChannelList.join(',');
            if (networkEnabled) {
                trace("Sub.activateNewChannelList: leaving " + removeChStr);
                leave(removeChStr);
            } else {
                trace("Sub.activateNewChannelList: not leaving (no network)" + removeChStr);
            }

            ArrayUtil.removeItems(_channels, newChannelList);
        }

        else if (operationType == "subscribe") {
            _channels = _channels.concat(newChannelList);
        }

        if (_channels.length > 0) {
            trace("Sub.activateNewChannelList: running executeSubscribeOperation " + _channels);
            executeSubscribeOperation();

        } else {
            trace("Sub.activateNewChannelList: no channels, will not continue with subscribe.");
            trace("Sub.activateNewChannelList: resetting lastTimetoken to 0");

            if (Settings.PANIC_ON_SILENCE == true) {
                dispatchEvent(new NetMonEvent(NetMonEvent.SUB_NET_DOWN));
            }

            dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, [0, "disconnect due to no active subscriptions"]));

            networkEnabled = false;
            clearInterval(retryInterval);
            lastReceivedTimetoken = "0";
            savedTimetoken = "0";
            subscribeConnection.close();
        }
    }

    public function unsubscribeAll(reason:Object = null):void {
        var allChannels:String = _channels.join(',');
        unsubscribe(allChannels, reason);
    }

    /*---------------------------SUBSCRIBE---------------------------*/
    private function executeSubscribeOperation():void {
        currentNW();

        UUID ||= PnUtils.getUID();

        trace("Sub.executeSubscribeOperation");

        var subscribeOperation:SubscribeOperation = new SubscribeOperation(origin);

        var tt:String = "";

        if (!networkEnabled) { // we are in retryMode

            tt = (Settings.RESUME_ON_RECONNECT == true) ? lastReceivedTimetoken : "0";
            trace("Sub.executeSubscribeOperation retry mode is set, choosing timetoken: " + tt);

        } else {

            tt = lastReceivedTimetoken;
            trace("Sub.executeSubscribeOperation resuming subscribe loop, choosing timetoken: " + tt);
        }

        var subObject:Object = {
            timetoken: tt,
            subscribeKey: subscribeKey,
            channel: this.channelsString,
            uid: UUID};
        subscribeOperation.setURL(null, subObject);

        subscribeOperation.addEventListener(OperationEvent.RESULT, onMessageReceived);
        subscribeOperation.addEventListener(OperationEvent.FAULT, onError);

        trace("Sub.executeSubscribeOperation executing subscribe request on wire.");
        subscribeConnection.executeGet(subscribeOperation);
    }

    protected function onMessageReceived(e:OperationEvent):void {

        if (!networkEnabled) {

            // recoverying! yay!

            if (Settings.PANIC_ON_SILENCE == true) {
                dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT, [1, "silence has been broken" ]));
                dispatchEvent(new NetMonEvent(NetMonEvent.SUB_NET_UP))
            }

            onNetworkEnable();
        }

        if (e.data == null) {
            Log.log("onMessageReceived: e.data is null at: " + lastReceivedTimetoken, Log.DEBUG);
            executeSubscribeOperation();
            return;
        }

        try {
            var messages:Array = e.data[0] as Array;

            savedTimetoken = lastReceivedTimetoken;
            lastReceivedTimetoken = e.data[1];

            var chStr:String = e.data[2];
        } catch (e:*) {
            Log.log("onMessageReceived: broken response array: " + e + " , TT: " + lastReceivedTimetoken, Log.DEBUG);
            executeSubscribeOperation();
            return
        }

        var multiplexRESPONSE:Boolean = chStr && chStr.length > 0 && chStr.indexOf(',') > -1;
        var presenceRESPONSE:Boolean = chStr && chStr.indexOf(PNPRES_PREFIX) > -1;
        var channel:String;

        if (presenceRESPONSE) {
            /*dispatchEvent(new SubscribeEvent(SubscribeEvent.PRESENCE, {channel: chStr, message: messages, timetoken: lastReceivedTimetoken}));*/
        } else {
            if (!messages) {
                return;
            }

            decryptMessages(messages);

            if (multiplexRESPONSE) {
                var chArray:Array = chStr.split(',');
                for (var i:int = 0; i < messages.length; i++) {
                    channel = chArray[i];
                    if (channelIsInChannelList(channel)) {
                        dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, {
                            channel: channel,
                            message: messages[i],
                            timetoken: lastReceivedTimetoken }));
                    }
                }
            } else {
                channel = chStr || _channels[0];
                for (var j:int = 0; j < messages.length; j++) {
                    dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, {
                        channel: channel,
                        message: messages[j],
                        timetoken: lastReceivedTimetoken }));
                }
            }
        }

        executeSubscribeOperation();
    }

    private function decryptMessages(messages:Array):void {
        if (messages) {
            for (var i:int = 0; i < messages.length; i++) {
                var msg:* = cipherKey.length > 0 ? PnJSON.parse(PnCrypto.decrypt(cipherKey, messages[i])) : messages[i];
                messages[i] = msg;
            }
        }
    }


    /*---------------------------LEAVE---------------------------------*/
    protected function leave(channel:String):void {

        var leaveOperation:LeaveOperation = new LeaveOperation(origin);
        leaveOperation.setURL(null, {
            channel: channel,
            uid: UUID,
            subscribeKey: subscribeKey
        });

        Pn.pn_internal::nonSubConnection.executeGet(leaveOperation);
    }

    protected function destroyOperation(op:Operation):void {
        op.destroy();
    }

    public function get origin():String {
        return _origin;
    }

    public function set origin(value:String):void {
        _origin = value;
    }

    public function get destroyed():Boolean {
        return _destroyed;
    }

    public function destroy():void {
        if (_destroyed) return;
        _destroyed = true;
        subscribeConnection.removeEventListener(OperationEvent.TIMEOUT, onError);
        subscribeConnection.destroy();
        subscribeConnection = null;
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

        trace("networkEnabled.setter called with NW_ENABLED = " + value)

        if (value == true) {
            trace("*** ENABLING NETWORK ***");
            //saveChannelsAndSubscribe();
        } else if (value == false) {
            trace("*** DISABLING NETWORK ***");
            //saveChannelsAndUnsubscribe();
        }
    }

    private function currentNW():void {
        trace("** Current NW **");

        trace("networkEnabled: " + networkEnabled);
        trace("retryCount: " + retryCount);
        trace("lastReceivedTimetoken: " + lastReceivedTimetoken);
        trace("savedTimetoken: " + savedTimetoken);
        trace("_channels: ") + _channels;
    }

    public function get retryCount():int {
        return _retryCount;
    }

    public function set retryCount(value:int):void {
        _retryCount = value;
    }


    public function set UUID(value:String):void {
        _UUID = value;
        trace("UUID SET in Subscribe: " + _UUID);

    }

    public function get UUID():String {
        return _UUID;
    }

    public function get networkEnabled():Boolean {
        return _networkEnabled;
    }

    public function get lastReceivedTimetoken():String {
        return _lastReceivedTimetoken;
    }

    public function set lastReceivedTimetoken(value:String):void {
        _lastReceivedTimetoken = value;
        trace("last received timetoken set to: " + value);
    }

    public function get savedTimetoken():String {
        return _savedTimetoken;
    }

    public function set savedTimetoken(value:String):void {
        trace("last saved timetoken set to: " + value);
        _savedTimetoken = value;
    }

    private function channelIsInChannelList(ch:String):Boolean {
        return (ch != null && _channels.indexOf(ch) > -1);
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

}
}