package com.pubnub.environment {
import com.pubnub.*;
import com.pubnub.log.*;

import flash.events.*;
import flash.net.*;
import flash.utils.*;

/**
 * ...
 * @author firsoff maxim, support@pubnub.com
 */
[Event(name="enable", type="com.pubnub.environment.NetMonEvent")]
[Event(name="disable", type="com.pubnub.environment.NetMonEvent")]
[Event(name="max_retries", type="com.pubnub.environment.NetMonEvent")]

public class NetMon extends EventDispatcher {

    private var pingDelayTimeout:int;
    private var pingTimeout:int;

    private var pingStartTime:int;
    private var _destroyed:Boolean;

    private var lastStatus:String
    private var _timeIsRunning:Boolean;
    private var sysMon:SysMon;
    private var _currentRetries:uint
    private var _maxRetries:uint = 100;

    private var loader:URLLoader;

    public function NetMon() {
        super(null);
        init();
    }

    private function init():void {

        loader = new URLLoader();
        loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderHTTPStatus);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);

        sysMon = new SysMon();
        sysMon.addEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);

        lastStatus = NetMonEvent.HTTP_DISABLE;
    }

    private function onLoaderError(e:IOErrorEvent):void {
        trace('onLoaderError');
    }


    private function onLoaderHTTPStatus(e:HTTPStatusEvent):void {
        if (_timeIsRunning == false) return;

        var pingEndTime:int = getTimer() - pingStartTime;

        clearTimeout(pingDelayTimeout);
        clearTimeout(pingTimeout);

        if (e.status == 0) {
            onError(null);
        } else {
            trace("onLoader");
            onComplete(null);
        }

        var pingOperationInterval:uint = lastStatus == NetMonEvent.HTTP_ENABLE ? Settings.PING_OPERATION_INTERVAL : Settings.PING_OPERATION_RETRY_INTERVAL;

        if (pingEndTime >= pingOperationInterval) {
            timePing();
        } else {
            pingDelayTimeout = setTimeout(timePing, pingOperationInterval - pingEndTime);
        }
    }

    private function timePing():void {
        trace('Ping!');
        if (_timeIsRunning == false) return;
        clearTimeout(pingTimeout);
        pingStartTime = getTimer();
        pingTimeout = setTimeout(onTimePingTimeout, Settings.PING_OPERATION_TIMEOUT);
        closeLoader();

        loader.load(new URLRequest(Settings.PING_OPERATION_URL));
    }

    private function onRestoreFromSleep(e:SysMonEvent):void {
        //trace('onRestoreFromSleep');
        lastStatus = null;
        timeReconnect();
    }

    private function onTimePingTimeout():void {
        //trace('onTimePingTimeout');
        onError(null);
        timePing();
    }

    private function onError(e:Event = null):void {
        //Log.log('PING : ERROR', Log.NORMAL);
        if (lastStatus == NetMonEvent.HTTP_ENABLE) {
            Log.log('RETRY_LOGGING:CONNECTION_HEARTBEAT: Network unavailable', Log.WARNING);
            dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_DISABLE));
        }

        lastStatus = NetMonEvent.HTTP_DISABLE;
        _currentRetries++;
        if (_currentRetries >= _maxRetries) {
            stop();
            Log.log('RETRY_LOGGING:RECONNECT_HEARTBEAT: maximum retries  of [' + _maxRetries + '] reached', Log.WARNING);
            dispatchEvent(new NetMonEvent(NetMonEvent.MAX_RETRIES));
        } else {
            Log.log('RETRY_LOGGING:RECONNECT_HEARTBEAT: Retrying [' + _currentRetries + '] of maximum [' + _maxRetries + '] attempts', Log.WARNING);
        }
    }

    private function onComplete(e:Event = null):void {
        _currentRetries = 0;
        if (lastStatus != NetMonEvent.HTTP_ENABLE) {
            Log.log('RETRY_LOGGING:CONNECTION_HEARTBEAT: Network available', Log.NORMAL);
            dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_ENABLE));
        }
        lastStatus = NetMonEvent.HTTP_ENABLE;
    }

    public function pingTimeStart():void {
        //trace(this, 'start : ' + _isRunning);
        if (_timeIsRunning) return;
        _currentRetries = 0;
        lastStatus = null;
        timeReconnect();
        sysMon.start();

    }

    private function timeReconnect():void {
        stop();
        _timeIsRunning = true;
        timePing();
    }

    public function stop():void {
        _timeIsRunning = false;
        lastStatus = null;
        sysMon.stop();
        clearTimeout(pingDelayTimeout);
        clearTimeout(pingTimeout);
    }

    public function destroy():void {
        if (_destroyed) return;
        stop();
        sysMon.stop();
        sysMon.removeEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
        sysMon = null;

        closeLoader();
        loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderHTTPStatus);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
        loader = null;
        _destroyed = true;
    }

    private function closeLoader():void {
        try {
            loader.close();
        } catch (err:Error) {
        }

    }

    public function get timeIsRunning():Boolean {
        return _timeIsRunning;
    }

    public function get currentRetries():uint {
        return _currentRetries;
    }

    public function get maxRetries():uint {
        return _maxRetries;
    }

    public function set maxRetries(value:uint):void {
        _maxRetries = value;
    }

    public function get destroyed():Boolean {
        return _destroyed;
    }
}
}