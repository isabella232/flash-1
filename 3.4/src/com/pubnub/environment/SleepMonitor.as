package com.pubnub.environment {
import flash.events.*;
import flash.utils.*;

/**
 * ...
 * @author firsoff maxim, support@pubnub.com
 */
[Event(name="restore_from_sleep", type="com.pubnub.environment.SleepMonitorEvent")]
public class SleepMonitor extends EventDispatcher {

    private var interval:int;
    private var sleepMonitorInterval:int = 1000; // check for elapsed time every n seconds
    private var sleepThreshold:int = 5000; // if this amount of time has elapsed since last ping, assume sleep resume
    private var lastTime:Number;
    private var _restoreFromSleep:Boolean;

    public function SleepMonitor() {
        super(null);
    }

    public function start():void {
        stop();
        lastTime = getTimer();
        interval = setInterval(ping, sleepMonitorInterval);
    }

    public function stop():void {
        clearInterval(interval);
    }

    private function ping():void {
        var currentTime:Number = getTimer();
        var elapsedTime:int = currentTime - lastTime;
        trace("sleep: " + elapsedTime);
        if (elapsedTime > sleepThreshold) {
            if (_restoreFromSleep == false) {
                _restoreFromSleep = true;
                dispatchEvent(new SleepMonitorEvent(SleepMonitorEvent.RESTORE_FROM_SLEEP, elapsedTime));
            }
        } else {
            _restoreFromSleep = false
        }
        lastTime = currentTime;
    }
}
}