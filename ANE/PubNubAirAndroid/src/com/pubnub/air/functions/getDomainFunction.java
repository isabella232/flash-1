package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class getDomainFunction extends SynchronousGetStringFunction implements FREFunction {
    @Override
    String methodName() {
        return "getDomain";
    }
}
