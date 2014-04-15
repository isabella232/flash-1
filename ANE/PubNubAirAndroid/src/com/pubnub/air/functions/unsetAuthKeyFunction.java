package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class unsetAuthKeyFunction extends SynchronousVoidFunction implements FREFunction {
    @Override
    String methodName() {
        return "unsetAuthKey";
    }
}
