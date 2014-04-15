package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class setHeartbeatFunction extends SynchronousSetIntFunction implements FREFunction {
    @Override
    String methodName() {
        return "setHeartbeat";
    }
}
