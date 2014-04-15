package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class setNonSubscribeTimeoutFunction extends SynchronousSetIntFunction implements FREFunction {
    @Override
    String methodName() {
        return "setHeartbeat";
    }
}
