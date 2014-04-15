package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class getUUIDFunction extends SynchronousGetStringFunction implements FREFunction {
    @Override
    String methodName() {
        return "getUUID";
    }
}
