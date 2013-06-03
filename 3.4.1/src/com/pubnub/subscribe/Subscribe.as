﻿package com.pubnub.subscribe {
import com.adobe.net.URI;
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

    protected var _host:String = "";
    protected var _origin:String = "";
    protected var _originalOrigin = "";
    protected var _retryCount:int = 0;
    protected var _retryInterval:int = 0;
    protected var _UUID:String = null;
    protected var _lastReceivedTimetoken:String = "0";
    protected var _savedTimetoken:String = "0";

    protected var _channels:Channel;
    protected var subscribeConnection:SubscribeConnection;
    protected var _networkEnabled:Boolean = false;
    private var _resumedData:Boolean = false;

    private var _net_status_up:Boolean = false;


    public function Subscribe(origin) {
        super(null);
        _origin = origin;
        _originalOrigin = origin;
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

        if (e.type == OperationEvent.CONNECT && _net_status_up == false) {

            dispatchEvent(new SystemMonitorEvent(SystemMonitorEvent.SUB_NET_UP));
            dispatchEvent(new SubscribeEvent(SubscribeEvent.CONNECT, [0, "connected"]));

        }

    }

    public function onError(e:OperationEvent):void {
        trace("Subscribe.onError");

        if (_net_status_up == true) {
            _net_status_up = false;
        }

        if (retryCount == Settings.MAX_ERROR_DEBOUNCES) {
            dispatchEvent(new SystemMonitorEvent(SystemMonitorEvent.SUB_NET_DOWN));
        }

        retryToConnect();
    }

    private function onNetworkEnable():void {
        Log.log("Sub.onNetworkEnable: Re-enabling network now!");

        clearInterval(retryInterval);
        retryCount = 0;
        retryInterval = 0;

        _networkEnabled = true;
    }

    public function retryToConnect():void {

        // if there is already a timer running, return.
        if (retryInterval > 0) {
            return;
        }

        //trace("Subscribe.delayedOnNetworkDisable: " + Settings.RECONNECT_RETRY_DELAY);
        cacheBust();

        if (Settings.RECONNECT_RETRY_DELAY > 0) {
            retryInterval = setInterval(onNetworkDisable, Settings.RECONNECT_RETRY_DELAY);
        } else {
            onNetworkDisable();
        }
    }

    private function cacheBust():void {
        if (retryCount == 0) {
            var randUint:uint = uint(Math.random() * 10000);

            var hostName:RegExp = /(.+?)(?=\.)/;

            var url:URI = new URI(_originalOrigin);

            var oldHostname = hostName.exec(host)[0];
            var newHostname = oldHostname + "-" + this.UUID.split("-")[0] + "-" + randUint.toString();

            var newURL = _originalOrigin.replace(oldHostname, newHostname);
            origin = newURL;
            //trace(origin);
        }
    }

    public function onNetworkDisable():void {

        subscribeConnection.close();

        Log.log("Sub.onNetworkDisable");

        if (Settings.ENABLE_MAX_RETRIES == true || retryCount <= Settings.MAX_ERROR_DEBOUNCES) {
            retryCount++;
        }

        networkEnabled = false;
        tryToConnect();
    }

    private function tryToConnect():void {

        if (networkEnabled) {
            return;
        }

        //trace("tryToConnect CALLED");
        Log.log("Sub.tryToConnect: " + retryCount + " / " + Settings.MAX_RECONNECT_RETRIES, Log.DEBUG, new SubscribeOperation("1"))

        if (channels && channels.channelList.length > 0) {

            if (Settings.ENABLE_MAX_RETRIES == true) {

                if (retryCount < Settings.MAX_RECONNECT_RETRIES && channels && channels.channelList.length > 0) {
                    Log.log("Sub.tryToConnect not yet at max retries. retrying.");
                    executeSubscribeOperation();

                } else {
                    Log.log("Sub.tryToConnect reached MAX_RETRIES!");
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

    public function subscribe(channelList:String, useThisTimeTokenInstead:String = null):void {
        //trace("Sub.subscribe");

        if (useThisTimeTokenInstead) {
            savedTimetoken = useThisTimeTokenInstead;
            lastReceivedTimetoken = useThisTimeTokenInstead;
        }
        //trace("Sub.subscribe " + channelList.toString());
        var reason:* = null;
        var opType:String = "subscribe";

        closeResubOrShutdown(opType, channelList, reason);
    }

    public function unsubscribe(channelList:String, reason:Object = null):void {
        //trace("unsubscribe");
        var opType:String = "unsubscribe";

        closeResubOrShutdown(opType, channelList, reason);
    }

    private function delayedLeave(removeChStr:String):void {
        setTimeout(leave, 2000, removeChStr);
    }

    private function closeResubOrShutdown(opType:String, channelList:String, reason:Object):void {
        //trace("closeResubOrShutdown");

        subscribeConnection.close();

        var channelsToModify:Array = channels.validateNewChannelList(opType, channelList, reason);
        var removeChStr:String = channelsToModify.join(',');

        if (networkEnabled) {
            //trace("Sub.activateNewChannelList: leaving " + removeChStr);
            delayedLeave(removeChStr);
        } else {
            //trace("Sub.activateNewChannelList: not leaving (no network)" + removeChStr);
        }

        var nextAction:String = channels.activateNewChannelList(channelsToModify, opType);

        if (nextAction == "resubscribe") {
            executeSubscribeOperation();
        }
        else if (nextAction == "shutdown") {

            Log.log("Sub.activateNewChannelList: no channels, Shutting down.");
            //trace("Sub.activateNewChannelList: resetting lastTimetoken to 0");

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

        //trace("Sub.executeSubscribeOperation");

        var subscribeOperation:SubscribeOperation = new SubscribeOperation(origin);

        var tt:String = "";

        if (!_networkEnabled) { // we are in retryMode
            tt = "0";
        } else {
            if (_resumedData) {
                tt = (Settings.RESUME_ON_RECONNECT == true) ? lastReceivedTimetoken : "0";
            } else {
                tt = _lastReceivedTimetoken;
            }
        }

        var subObject:Object = {
            timetoken: tt,
            subscribeKey: subscribeKey,
            channel: channels.channelsString(),
            uid: UUID};
        subscribeOperation.setURL(null, subObject);

        subscribeOperation.addEventListener(OperationEvent.RESULT, onMessageReceived);
        subscribeOperation.addEventListener(OperationEvent.FAULT, onError);

        //trace("Sub.executeSubscribeOperation executing subscribe request on wire.");
        subscribeConnection.executeGet(subscribeOperation);
    }

    protected function onMessageReceived(e:OperationEvent):void {

        if (!_networkEnabled) {

            // recoverying! yay!

            onNetworkEnable();
            _resumedData = true;
            executeSubscribeOperation();
            return;
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

            var channel:String = e.data[2];

            // no messages, with timetoken response (ping handshake)
            if (_net_status_up == false) {
                dispatchEvent(new SystemMonitorEvent(SystemMonitorEvent.SUB_NET_UP));
                _net_status_up = true;
                retryCount = 0;
            }

        } catch (e:*) {
            Log.log("onMessageReceived: broken response array: " + e + " , TT: " + lastReceivedTimetoken, Log.DEBUG);

            lastReceivedTimetoken = savedTimetoken;
            executeSubscribeOperation();
            return
        }

        var multiplexRESPONSE:Boolean = channel && channel.length > 0 && channel.indexOf(',') > -1;
        var presenceRESPONSE:Boolean = channel && channel.indexOf(PNPRES_PREFIX) > -1;
        var channel:String;

        if (presenceRESPONSE) {
            dispatchEvent(new SubscribeEvent(SubscribeEvent.PRESENCE, {channel: channel, message: messages, timetoken: lastReceivedTimetoken}));
        } else {
            if (!messages) {
                //resumedData = false;
                return;
            }

            decryptMessages(messages);

            if (multiplexRESPONSE) {
                var chArray:Array = channel.split(',');
                for (var i:int = 0; i < messages.length; i++) {
                    channel = chArray[i];
                    if (channels.channelIsInChannelList(channel)) {
                        dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, {
                            channel: channel,
                            message: messages[i],
                            timetoken: lastReceivedTimetoken,
                            resumedData: _resumedData
                        }));
                    }
                }
            } else {
                channel = channel || channels.channelList[0];
                for (var j:int = 0; j < messages.length; j++) {
                    dispatchEvent(new SubscribeEvent(SubscribeEvent.DATA, {
                        channel: channel,
                        message: messages[j],
                        timetoken: lastReceivedTimetoken,
                        resumedData: _resumedData
                    }));
                }
            }
        }

        _resumedData = false;
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

        //trace("networkEnabled.setter called with NW_ENABLED = " + value)

        if (value == true) {
            //trace("*** ENABLING NETWORK ***");
            //saveChannelsAndSubscribe();
        } else if (value == false) {
            //trace("*** DISABLING NETWORK ***");
            //saveChannelsAndUnsubscribe();
        }
    }

    private function currentNW():void {
//        trace("** Current NW **");
//
//        trace("networkEnabled: " + networkEnabled);
//        trace("retryCount: " + retryCount);
//        trace("lastReceivedTimetoken: " + lastReceivedTimetoken);
//        trace("savedTimetoken: " + savedTimetoken);
//        trace("_channels: ") + _channels;
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
        //trace("UUID SET in Subscribe: " + _UUID);

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
        //trace("last received timetoken set to: " + value);
    }

    public function get savedTimetoken():String {
        return _savedTimetoken;
    }

    public function set savedTimetoken(value:String):void {
        //trace("last saved timetoken set to: " + value);
        _savedTimetoken = value;
    }

    public function get channels():Channel {
        return _channels;
    }

    public function get host():String {
        return _host;
    }

    public function set host(value:String):void {
        _host = value;
    }
}
}