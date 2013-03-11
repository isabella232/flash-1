package com.pubnub.environment {
import com.pubnub.*;
import com.pubnub.log.*;

import flash.events.*;
import flash.net.*;
import flash.utils.*;

/**
 * ...
 * @author geremy cohen, support@pubnub.com
 */
[Event(name="enable", type="com.pubnub.environment.AuxNetMonEvent")]
[Event(name="disable", type="com.pubnub.environment.AuxNetMonEvent")]
[Event(name="max_retries", type="com.pubnub.environment.AuxNetMonEvent")]

public class AuxNetMon extends EventDispatcher {

    private var pingDelayTimeout:int;
    private var pingTimeout:int;

    private var pingStartTime:int;
    private var _destroyed:Boolean;

    private var lastStatus:String
    private var _timeIsRunning:Boolean;
    private var sysMon:SysMon;
    private var _currentRetries:uint
    private var _maxRetries:uint = 100;

    private var nloader:URLLoader;

    public function AuxNetMon() {
        super(null);
        init();
    }

    private function init():void {

        nloader = new URLLoader();
        nloader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onNloaderHTTPStatus);
        nloader.addEventListener(IOErrorEvent.IO_ERROR, onNloaderError);

        sysMon = new SysMon();
        sysMon.addEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);

        lastStatus = AuxNetMonEvent.HTTP_DISABLE;
    }


    private function onNloaderError(e:IOErrorEvent):void {
        trace('NLoader! Error!');
    }

    private function onNloaderHTTPStatus(e:HTTPStatusEvent):void {
        if (_timeIsRunning == false) return;

        var pingEndTime:int = getTimer() - pingStartTime;

        clearTimeout(pingDelayTimeout);
        clearTimeout(pingTimeout);

        if (e.status == 0) {
            onError(null);
        } else {
            trace("onNloaderHTTPStatus");
            onComplete(null);
        }

        var pingOperationInterval:uint = lastStatus == AuxNetMonEvent.HTTP_ENABLE ? Settings.REMOTE_OPERATION_INTERVAL : Settings.REMOTE_OPERATION_RETRY_INTERVAL;

        if (pingEndTime >= pingOperationInterval) {
            timePing();
        } else {
            pingDelayTimeout = setTimeout(timePing, pingOperationInterval - pingEndTime);
        }
    }

    private function timePing():void {
        trace('NL Ping!');
        if (_timeIsRunning == false) return;
        clearTimeout(pingTimeout);
        pingStartTime = getTimer();
        pingTimeout = setTimeout(onTimePingTimeout, Settings.REMOTE_OPERATION_TIMEOUT);
        closeLoader();

        nloader.load(new URLRequest(Settings.REMOTE_OPERATION_URL));
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
            //Log.log('RETRY_LOGGING:CONNECTION_HEARTBEAT: Network unavailable', Log.WARNING);
            dispatchEvent(new AuxNetMonEvent(AuxNetMonEvent.HTTP_DISABLE));


        lastStatus = AuxNetMonEvent.HTTP_DISABLE;
        _currentRetries++;
        if (_currentRetries >= _maxRetries) {
            stop();
            //Log.log('RETRY_LOGGING:RECONNECT_HEARTBEAT: maximum retries  of [' + _maxRetries + '] reached', Log.WARNING);
            dispatchEvent(new AuxNetMonEvent(AuxNetMonEvent.MAX_RETRIES));
        } else {
            Log.log('RETRY_LOGGING:RECONNECT_HEARTBEAT: Retrying [' + _currentRetries + '] of maximum [' + _maxRetries + '] attempts', Log.WARNING);
        }
    }

    private function onComplete(e:Event = null):void {
        _currentRetries = 0;
        if (lastStatus == AuxNetMonEvent.HTTP_ENABLE) {
            //Log.log('RETRY_LOGGING:CONNECTION_HEARTBEAT: Network available', Log.NORMAL);
            dispatchEvent(new AuxNetMonEvent(AuxNetMonEvent.HTTP_ENABLE));
        }
        lastStatus = AuxNetMonEvent.HTTP_ENABLE;
    }

    public function pingTimeStart():void {
        //trace(this, 'start : ' + _isRunning);
        if (_timeIsRunning) return;
        _currentRetries = 0;
        lastStatus = null;
        timeReconnect();
        sysMon.start();

        nloader.load(new URLRequest(Settings.REMOTE_OPERATION_URL));


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
        nloader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onNloaderHTTPStatus);
        nloader.removeEventListener(IOErrorEvent.IO_ERROR, onNloaderError);
        nloader = null;
        _destroyed = true;
    }

    private function closeLoader():void {
        try {
            nloader.close();
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