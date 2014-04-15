package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class uuidFunction extends SynchronousGetStringFunction implements FREFunction {
    @Override
    String methodName() {
        return "uuid";
    }
}
