package com.pubnub.subscribe {
import com.pubnub.*;
import com.pubnub.connection.*;
import com.pubnub.environment.*;
import com.pubnub.json.*;
import com.pubnub.log.Log;
import com.pubnub.operation.*;

import flash.events.*;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

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
    protected var _retryTimer:int = 0;
    protected var _UUID:String = null;
    protected var _lastReceivedTimetoken:String = "0";
    protected var _savedTimetoken:String = "0";
    protected var _destroyed:Boolean;
    protected var _channels:Array;
    protected var savedChannels:Array;
    protected var subscribeConnection:SubscribeConnection;
    protected var _networkEnabled:Boolean = false;

    public function Subscribe() {
        super(null);
        init();
    }

    protected function init():void {
        _channels = [];

        subscribeConnection = new SubscribeConnection();
        addEventListener(OperationEvent.TIMEOUT, onTimeout);
        subscribeConnection.addEventListener(OperationEvent.CONNECT, onConnect);
        subscribeConnection.addEventListener(OperationEvent.TIMEOUT, onTimeout);
        subscribeConnection.addEventListener(OperationEvent.CONNECTION_ERROR, onConnectError);
    }

    protected function onConnect(e:OperationEvent):void {
        Log.log("Subscribe: onConnect", Log.DEBUG);

        if (!networkEnabled) {
            onNetworkEnable();
        }
    }

    private function onNetworkEnable():void {

        trace("Sub.onNetworkEnable");
        dispatchEvent(new NetMonEvent(NetMonEvent.SUB_NET_UP));

        if (!networkEnabled) {
            trace("Sub.onNetworkEnable: Re-enabling network now!");
            clearTimeout(_retryTimer);
            retryCount = 0;
            networkEnabled = true;

            subscribeToSavedOrExisting();
        }
    }

    private function onNetworkDisable():void {
        trace("Sub.onNetworkDisable");
        saveChannelsAndUnsubscribe();
        networkEnabled = false;
        retryCount++;
    }

    public function onTimeout(e:OperationEvent):void {
        trace("Subscribe.onTimeout")
        delayedSubscribeRetry(new NetMonEvent(NetMonEvent.SUB_NET_DOWN));
    }

    private function onConnectError(e:OperationEvent):void {
        trace("Subscribe.onConnectError")

        if (!networkEnabled) {
            dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ 0, Errors.NETWORK_UNAVAILABLE]));
            delayedSubscribeRetry(new NetMonEvent(NetMonEvent.SUB_NET_DOWN));
        }

    }

    private function delayedSubscribeRetry(e:NetMonEvent):void {
        dispatchEvent(new NetMonEvent(NetMonEvent.SUB_NET_DOWN));

        trace("Subscribe.delayedSubscribeRetry: " + Settings.RECONNECT_RETRY_DELAY);

        clearTimeout(_retryTimer);
        onNetworkDisable();

        trace("Sub.delayedSubscribeRetry settingTimeout");

        _retryTimer = setTimeout(attemptDelayedResubscribe, Settings.RECONNECT_RETRY_DELAY, e);
    }

    private function attemptDelayedResubscribe(e:NetMonEvent):void {
        Log.log("Sub.attemptDelayedResubscribe: " + retryCount + " / " + Settings.MAX_RECONNECT_RETRIES, Log.DEBUG, new SubscribeOperation("1"))

        if (retryCount < Settings.MAX_RECONNECT_RETRIES) {
            trace("Sub.attemptDelayedResubscribe not yet at max retries. retrying.");
            subscribeToSavedOrExisting();
        } else {
            dispatchEvent(new EnvironmentEvent(EnvironmentEvent.SHUTDOWN, Errors.NETWORK_RECONNECT_MAX_RETRIES_EXCEEDED));
        }
    }

    public function subscribe(channelList:String, useThisTimeokenInstead:String = null):Boolean {
        if (useThisTimeokenInstead) {
            savedTimetoken = useThisTimeokenInstead;
            lastReceivedTimetoken = useThisTimeokenInstead;
        }
        trace("Sub.subscribe " + channelList.toString());
        return modifyChannelListAndResubscribe("subscribe", channelList).length > 0;
    }

    public function unsubscribe(channelList:String, reason:Object = null):Boolean {

        var channelsToModify:Array = modifyChannelListAndResubscribe("unsubscribe", channelList, reason);
        return channelsToModify.length > 0;
    }

    protected function modifyChannelListAndResubscribe(operationType:String, channelList:String, reason:Object = null):Array {
        trace("modifyChannelListAndResubscribe: " + operationType);

        if (!isNetworkEnabled() && operationType == "unsubscribe") {
            trace("modifyChannelListAndResubscribe: net not enabled, so returning a blank array");
            return [];
        }

        if (!isChannelListValid(channelList)) {
            trace("modifyChannelListAndResubscribe: not a valid channellist, so returning a blank array");
            dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ 0, Errors.SUBSCRIBE_CHANNEL_TOO_BIG_OR_NULL, channels]));
            return [];
        }

        var channelsToModify:Array = [];
        var channelListAsArray:Array = channelList.split(',');
        var channelString:String;
        channelString = buildChannelListBasedOnOperation(channelListAsArray, channelString, operationType, channelsToModify);

        if (operationType == "subscribe") {
            trace("modifyChannelListAndResubscribe: subscribe calling resubscribeWithNewChannelList with " + channelsToModify.toString());

            resubscribeWithNewChannelList(channelsToModify);
        } else if (operationType == "unsubscribe") {
            trace("modifyChannelListAndResubscribe: unsubscribe calling resubscribeWithNewChannelList with " + channelsToModify.toString());

            resubscribeWithNewChannelList(null, channelsToModify);
        }

        return channelsToModify;
    }

    private function buildChannelListBasedOnOperation(channelListAsArray:Array, channelString:String, operationType:String, channelsToModify:Array):String {
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
        return channelString;
    }

    private function resubscribeWithNewChannelList(channelsToAdd:Array = null, channelsToRemove:Array = null, reason:Object = null):void {

        trace("Sub.resubscribeWithNewChannelList");

        var addFlag:Boolean = channelsToAdd && channelsToAdd.length > 0;
        var removeFlag:Boolean = channelsToRemove && channelsToRemove.length > 0;
        if (addFlag || removeFlag) {

            subscribeConnection.close();

            if (removeFlag) {
                var removeChStr:String = channelsToRemove.join(',');
                leave(removeChStr);
                trace("Sub.resubscribeWithNewChannelList: leaving " + removeChStr);

                ArrayUtil.removeItems(_channels, channelsToRemove);
                dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, { channel: removeChStr, reason: (reason ? reason : '') }));
            }

            if (addFlag) {
                _channels = _channels.concat(channelsToAdd);
            }

            if (_channels.length > 0) {
                trace("Sub.resubscribeWithNewChannelList: running executeSubscribeOperation " + _channels);
                executeSubscribeOperation();

            } else {
                trace("Sub.resubscribeWithNewChannelList: no channels, will not continue with subscribe.");
                if (savedChannels == null || savedChannels && savedChannels.length == 0) {
                    trace("Sub.resubscribeWithNewChannelList: resetting lastTimetoken to 0");
                    lastReceivedTimetoken = "0"
                }
            }
        }
    }

    public function unsubscribeAll(reason:Object = null):void {
        if (!isNetworkEnabled()) {
            return;
        }

        doUnsubscribeAll(reason);
    }

    private function doUnsubscribeAll(reason:Object = null):void {
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

        if (!networkEnabled) {
            tt = (Settings.RESUME_ON_RECONNECT == true) ? lastReceivedTimetoken : "0";
            trace("Sub.executeSubscribeOperation retry mode is set, choosing timetoken: " + tt);
        } else {
            tt = lastReceivedTimetoken;
            trace("Sub.executeSubscribeOperation retry mode is NOT set, choosing timetoken: " + tt);
        }

        var subObject = {
            timetoken: tt,
            subscribeKey: subscribeKey,
            channel: this.channelsString,
            uid: UUID};
        subscribeOperation.setURL(null, subObject);
        subscribeOperation.addEventListener(OperationEvent.RESULT, onMessageReceived);
        subscribeOperation.addEventListener(OperationEvent.FAULT, onConnectError);

        trace("Sub.executeSubscribeOperation executing subscribe request on wire.");
        subscribeConnection.executeGet(subscribeOperation);
    }

    protected function onMessageReceived(e:OperationEvent):void {


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
        } catch (e) {
            Log.log("onMessageReceived: broken response array: " + e + " , TT: " + lastReceivedTimetoken, Log.DEBUG);
            executeSubscribeOperation();
            return
        }

        var multiplexRESPONSE:Boolean = chStr && chStr.length > 0 && chStr.indexOf(',') > -1;
        var presenceRESPONSE:Boolean = chStr && chStr.indexOf(PNPRES_PREFIX) > -1;
        var channel:String;

        if (presenceRESPONSE) {
            dispatchEvent(new SubscribeEvent(SubscribeEvent.PRESENCE, {channel: chStr, message: messages, timetoken: lastReceivedTimetoken}));
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


    // TODO: Old onConnectError -- See if our new one is better!
//    protected function onConnectError(e:OperationEvent):void {
//        //trace('onSubscribeError!');
//        dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ -1, Errors.SUBSCRIBE_CHANNEL_ERROR]));
//        destroyOperation(e.target as Operation);
//    }

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
        unsubscribeAndLeave();
        subscribeConnection.removeEventListener(OperationEvent.TIMEOUT, onTimeout);
        subscribeConnection.destroy();
        subscribeConnection = null;
    }

    public function unsubscribeAndLeave(reason:String = null):void {
        doUnsubscribeAll(reason);
        subscribeConnection.close();
        if (_channels.length > 0) {
            leave(_channels.join(','));
        }
        _channels.length = 0;

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

        trace("NW_ENABLED = " + value)

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
        trace("savedChannels: ") + savedChannels;
    }

    // on false
    public function saveChannelsAndUnsubscribe():void {
        savedChannels = _channels.concat();
        trace("Sub.saveChannelsAndUnsubscribe: savedChannels: " + savedChannels);

        unsubscribeAndLeave('network disabled, retrying to connect');
    }

    // on true
    public function subscribeToSavedOrExisting():void {

        trace("Sub.subscribeToSavedOrExisting savedChannels/_channels: " + savedChannels + " / " + _channels);

        if (savedChannels && savedChannels.length > 0) {
            trace("Sub.readSavedChannelsAndSubscribe subscribing to savedChannels");
            subscribe(savedChannels.join(','));
            savedChannels = [];
        } else {
            trace("Sub.readSavedChannelsAndSubscribe subscribing to _channels");
            subscribe(_channels.join(","));
        }
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