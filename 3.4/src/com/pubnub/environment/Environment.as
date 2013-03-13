package com.pubnub.environment {
import com.pubnub.*;
import com.pubnub.log.Log;
import com.pubnub.operation.Operation;

import flash.events.*;

/**
 * ...
 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
 */
[Event(name="shutdown", type="com.pubnub.environment.EnvironmentEvent")]

public class Environment extends EventDispatcher {
    private var _origin:String;

    //private var netMon:NetMon;
    //private var auxNetMon:AuxNetMon;

    private var sysMon:SysMon;
    private var _networkEnabled:Boolean;
    private var lastHTTPDisabledTime:int = 0;
    private var maxTimeout:int;
    private var _firstRun:Boolean;

    public function Environment(origin:String) {
        super();
        _origin = origin;
        init();
    }

    public function start():void {

//        netMon.pingTimeStart();
//        auxNetMon.pingTimeStart();

        // This is to just stub the "init ping"

        dispatchEvent(new NetMonEvent(NetMonEvent.HTTP_ENABLE_VIA_SUBSCRIBE_TIMEOUT));

        sysMon.start();
        lastHTTPDisabledTime = 0;
    }

    public function stop():void {
        _networkEnabled = false;
//        netMon.stop();
//        auxNetMon.stop();

        sysMon.stop();
    }

    public function destroy():void {
        stop();

//        netMon.destroy();
//        netMon.removeEventListener(NetMonEvent.HTTP_DISABLE, onHTTPDisable);
//        netMon.removeEventListener(NetMonEvent.HTTP_ENABLE, onHTTPEnable);
//        netMon.removeEventListener(NetMonEvent.MAX_RETRIES, onMaxRetries);
//        netMon = null;
//
//        auxNetMon.destroy();
//        auxNetMon.removeEventListener(AuxNetMonEvent.HTTP_DISABLE, onAuxHTTPDisable);
//        auxNetMon.removeEventListener(AuxNetMonEvent.HTTP_ENABLE, onAuxHTTPEnable);
//        auxNetMon.removeEventListener(AuxNetMonEvent.MAX_RETRIES, onAuxMaxRetries);
//        auxNetMon = null;

        sysMon.removeEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
        sysMon = null;
    }

    private function init():void {
//        netMon = new NetMon();
//        auxNetMon = new AuxNetMon();
//
//        netMon.maxRetries = Settings.MAX_RECONNECT_RETRIES;
//        netMon.addEventListener(NetMonEvent.HTTP_DISABLE, onHTTPDisable);
//        netMon.addEventListener(NetMonEvent.HTTP_ENABLE, onHTTPEnable);
//        netMon.addEventListener(NetMonEvent.MAX_RETRIES, onMaxRetries);
//
//        auxNetMon.maxRetries = Settings.MAX_RECONNECT_RETRIES;
//        auxNetMon.addEventListener(AuxNetMonEvent.HTTP_DISABLE, onAuxHTTPDisable);
//        auxNetMon.addEventListener(AuxNetMonEvent.HTTP_ENABLE, onAuxHTTPEnable);
//        auxNetMon.addEventListener(AuxNetMonEvent.MAX_RETRIES, onAuxMaxRetries);
        

        sysMon = new SysMon();
        sysMon.addEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);

        maxTimeout = Settings.MAX_RECONNECT_RETRIES * Math.max(Settings.PING_OPERATION_RETRY_INTERVAL, Settings.PING_OPERATION_INTERVAL);
    }

//    private function onMaxRetries(e:NetMonEvent):void {
//        dispatchEvent(new EnvironmentEvent(EnvironmentEvent.SHUTDOWN, Errors.NETWORK_RECONNECT_MAX_RETRIES_EXCEEDED));
//    }

//    private function onAuxMaxRetries(e:AuxNetMonEvent):void {
//        Log.log("onAuxMaxRetries", Log.DEBUG);
//    }

    private function onRestoreFromSleep(e:SysMonEvent):void {
        if (e.timeout > maxTimeout) {
            dispatchEvent(new EnvironmentEvent(EnvironmentEvent.SHUTDOWN, Errors.NETWORK_RECONNECT_MAX_TIMEOUT_EXCEEDED));
        } else {
            dispatchEvent(new EnvironmentEvent(EnvironmentEvent.RECONNECT));
        }
    }

//    private function onAuxHTTPEnable(e:AuxNetMonEvent):void {
//        Log.log("Aux Connect Success to " + Settings.REMOTE_OPERATION_URL, Log.DEBUG, new Operation("Aux Ping"));
//    }
//
//    private function onAuxHTTPDisable(e:AuxNetMonEvent):void {
//        Log.log("Aux Connect Failed to " + Settings.REMOTE_OPERATION_URL, Log.DEBUG, new Operation("Aux Ping"));
//    }

//    private function onHTTPEnable(e:NetMonEvent):void {
//        Log.log("Ping Connect Success to " + Settings.PING_OPERATION_URL, Log.DEBUG, new Operation("Sub Ping"));
//        _firstRun = true;
//        _netwotkEnabled = false;
//        dispatchEvent(e);
//    }
//
//    private function onHTTPDisable(e:NetMonEvent):void {
//        Log.log("Ping Connect Failed to " + Settings.PING_OPERATION_URL, Log.DEBUG, new Operation("Sub Ping"));
//        _netwotkEnabled = false;
//        Log.log("Subscribe Failed!", Log.DEBUG);
//        dispatchEvent(e);
//    }
    
    

    public function get origin():String {
        return _origin;
    }

    public function set origin(value:String):void {
        _origin = value;
    }

    public function get networkEnabled():Boolean {
        return _networkEnabled;
    }


    public function get firstRun():Boolean {
        return _firstRun;
    }
}
}