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
import flash.utils.setTimeout;

use namespace pn_internal;

public class Subscribe extends EventDispatcher {

    static public const PNPRES_PREFIX:String = '-pnpres';
    static public const SUBSCRIBE:String = 'subscribe';

    public var subscribeKey:String;
    public var cipherKey:String;
    public var secretKey:String;

    protected var _origin:String = "";
    protected var _retryCount:int = 0;
    protected var _retryInterval:int = 0;
    protected var _UUID:String = null;
    protected var _lastReceivedTimetoken:String = "0";
    protected var _savedTimetoken:String = "0";

    protected var _channels:Channel;
    protected var subscribeConnection:SubscribeConnection;
    protected var _networkEnabled:Boolean = false;
	
	private var _net_status_up:Boolean = false;
    private var _retry_mode:Boolean = false;


    public function Subscribe(origin) {
        super(null);
        _origin = origin;
        init();
    }

    protected function init():void {
        _channels = new Channel();

        subscribeConnection = new SubscribeConnection();
        addEventListener(OperationEvent.TIMEOUT, onError);
        subscribeConnection.addEventListener(OperationEvent.CONNECT, onConnect);
        subscribeConnection.addEventListener(OperationEvent.TIMEOUT, onError);
        subscribeConnection.addEventListener(OperationEvent.CONNECTION_ERROR, onError);
    }

    protected function onConnect(e:OperationEvent):void {
        Log.log("Subscribe: onConnect", Log.DEBUG);

        if (e.type == OperationEvent.CONNECT && _net_status_up == false && _retry_mode == false) {

            dispatchEvent(new SystemMonitorEvent(SystemMonitorEvent.SUB_NET_UP));
            dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT, [0, "connected"]));

            _net_status_up = true;
        }

    }

    public function onError(e:OperationEvent):void {
        trace("Subscribe.onError");

        if (Settings.NET_DOWN_ON_SILENCE == true) {
            if (e.type == OperationEvent.TIMEOUT && _net_status_up == true) {
                dispatchEvent(new SystemMonitorEvent(SystemMonitorEvent.SUB_NET_DOWN));
                _net_status_up = false;
                _retry_mode = true;
            }
        }

        retryToConnect();
    }

    private function onNetworkEnable():void {
        trace("Sub.onNetworkEnable: Re-enabling network now!");

        clearInterval(retryInterval);
        retryInterval = 0;

        networkEnabled = true;
    }

    public function retryToConnect():void {

        // if there is already a timer running, return.
        if (retryInterval > 0) {
            return;
        }

        trace("Subscribe.delayedOnNetworkDisable: " + Settings.RECONNECT_RETRY_DELAY);
        retryInterval = setInterval(onNetworkDisable, Settings.RECONNECT_RETRY_DELAY);
    }

    public function onNetworkDisable():void {

        subscribeConnection.close();

        trace("Sub.onNetworkDisable");

        if (Settings.NET_DOWN_ON_SILENCE == true) {
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

        if (channels && channels.channelList.length > 0) {

            if (Settings.NET_DOWN_ON_SILENCE == true) {

                if (retryCount < Settings.MAX_RECONNECT_RETRIES && channels && channels.channelList.length > 0) {
                    trace("Sub.tryToConnect not yet at max retries. retrying.");
                    executeSubscribeOperation();

                } else {
                    trace("Sub.tryToConnect reached MAX_RETRIES!");
                    unsubscribeAll();
                }

            } else {
                executeSubscribeOperation();
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

    public function subscribe(channelList:String, useThisTimeokenInstead:String = null):void {
        trace("Sub.subscribe");

        if (useThisTimeokenInstead) {
            savedTimetoken = useThisTimeokenInstead;
            lastReceivedTimetoken = useThisTimeokenInstead;
        }
        trace("Sub.subscribe " + channelList.toString());
        var reason:* = null;
        var opType:String = "subscribe";

        closeResubOrShutdown(opType, channelList, reason);
    }

    public function unsubscribe(channelList:String, reason:Object = null):void {
        trace("unsubscribe");
        var opType:String = "unsubscribe";

        closeResubOrShutdown(opType, channelList, reason);
    }

    private function delayedLeave(removeChStr:String):void {
        setTimeout(leave, 2000, removeChStr);
    }

    private function closeResubOrShutdown(opType:String, channelList:String, reason:Object):void {
        trace("closeResubOrShutdown");

        subscribeConnection.close();

        var channelsToModify:Array = channels.validateNewChannelList(opType, channelList, reason);
        var removeChStr:String = channelsToModify.join(',');

        if (networkEnabled) {
            trace("Sub.activateNewChannelList: leaving " + removeChStr);
            delayedLeave(removeChStr);
        } else {
            trace("Sub.activateNewChannelList: not leaving (no network)" + removeChStr);
        }

        var nextAction:String = channels.activateNewChannelList(channelsToModify, opType);

        if (nextAction == "resubscribe") {
            executeSubscribeOperation();
        }
        else if (nextAction == "shutdown") {

            trace("Sub.activateNewChannelList: no channels, will not continue with subscribe.");
            trace("Sub.activateNewChannelList: resetting lastTimetoken to 0");

            var shutdownReason:String = _net_status_up ? "unsubscribed from all channels" : "maximum reconnect retries exceeded";

            dispatchEvent(new SubscribeEvent(SubscribeEvent.DISCONNECT, [0, shutdownReason]));

            if (_net_status_up == true) {
                dispatchEvent(new SystemMonitorEvent(SystemMonitorEvent.SUB_NET_DOWN));
            }

            _net_status_up = false;
            networkEnabled = false;
            clearInterval(retryInterval);

            lastReceivedTimetoken = "0";
            savedTimetoken = "0";
        }
    }

    public function unsubscribeAll(reason:Object = null):void {
        var allChannels:String = channels.channelsString();
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
            channel: channels.channelsString(),
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

            if (Settings.NET_DOWN_ON_SILENCE == true) {
                if (messages.length > 0 && _net_status_up == false) {
                    dispatchEvent(new SystemMonitorEvent(SystemMonitorEvent.SUB_NET_UP));
                    _net_status_up = true;
                    _retry_mode = false;
                    retryCount = 0;
                }
            }

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
                    if (channels.channelIsInChannelList(channel)) {
                        dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, {
                            channel: channel,
                            message: messages[i],
                            timetoken: lastReceivedTimetoken }));
                    }
                }
            } else {
                channel = chStr || channels.channelList[0];
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

    protected function destroyOperation(op:Operation):void {
        op.destroy();
    }

    public function get origin():String {
        return _origin;
    }

    public function set origin(value:String):void {
        _origin = value;
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

    public function get retryInterval():int {
        return _retryInterval;
    }

    public function set retryInterval(value:int):void {
        _retryInterval = value;
        _channels._retryInterval = value;
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

    public function get channels():Channel {
        return _channels;
    }


}
}