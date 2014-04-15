package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class getHeartbeatFunction extends SynchronousGetIntFunction implements FREFunction {
    @Override
    String methodName() {
        return "getHeartbeat";
    }
}
