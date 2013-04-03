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

    private var sysMon:SysMon;
    private var lastHTTPDisabledTime:int = 0;
    private var _firstRun:Boolean;

    public function Environment(origin:String) {
        super();
        _origin = origin;
        init();
    }

    public function start():void {
        sysMon.start();
        lastHTTPDisabledTime = 0;
    }

    public function stop():void {
        sysMon.stop();
    }

    public function destroy():void {
        stop();
        sysMon.removeEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
        sysMon = null;
    }

    private function init():void {
        sysMon = new SysMon();
        sysMon.addEventListener(SysMonEvent.RESTORE_FROM_SLEEP, onRestoreFromSleep);
    }

    private function onRestoreFromSleep(e:SysMonEvent):void {
        dispatchEvent(new EnvironmentEvent(EnvironmentEvent.SLEEP_RESUME));
    }

    public function get origin():String {
        return _origin;
    }

    public function set origin(value:String):void {
        _origin = value;
    }

    public function get firstRun():Boolean {
        return _firstRun;
    }
}
}