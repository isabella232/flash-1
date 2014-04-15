package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class shutdownFunction extends SynchronousVoidFunction implements FREFunction {
    @Override
    String methodName() {
        return "shutdown";
    }
}
