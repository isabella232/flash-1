package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class getAuthKeyFunction extends SynchronousGetStringFunction implements FREFunction {
    @Override
    String methodName() {
        return "getAuthKey";
    }
}
