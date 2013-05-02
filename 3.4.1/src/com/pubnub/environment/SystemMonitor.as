package com.pubnub.environment {
import com.pubnub.Settings;
import com.pubnub.log.Log;

import flash.events.*;
import flash.utils.*;

/**
 * ...
 * @author firsoff maxim, support@pubnub.com
 */
[Event(name="restore_from_sleep", type="com.pubnub.environment.SystemMonitorEvent")]
public class SystemMonitor extends EventDispatcher {

    private var interval:int;
    private var sleepMonitorInterval:int = 1000; // check for elapsed time every n seconds
    private var sleepThreshold:int = Settings.SLEEP_THRESHOLD; // if this amount of time has elapsed since last ping, assume sleep resume
    private var lastTime:Number;
    private var _restoreFromSleep:Boolean;

    public function SystemMonitor() {
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
        if (elapsedTime > sleepThreshold) {
            if (_restoreFromSleep == false && Settings.DETECT_SLEEP == true) {
                _restoreFromSleep = true;
                dispatchEvent(new SystemMonitorEvent(SystemMonitorEvent.RESTORE_FROM_SLEEP, elapsedTime));
                Log.log("restore from sleep event has occurred.")
            }
        } else {
            _restoreFromSleep = false
        }
        lastTime = currentTime;
    }
}
}