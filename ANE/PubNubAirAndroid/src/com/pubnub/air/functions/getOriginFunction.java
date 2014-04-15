package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class getOriginFunction extends SynchronousGetStringFunction implements FREFunction {
    @Override
    String methodName() {
        return "getOrigin";
    }
}
