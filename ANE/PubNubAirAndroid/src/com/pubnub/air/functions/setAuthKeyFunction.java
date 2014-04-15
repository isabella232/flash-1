package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class setAuthKeyFunction extends SynchronousSetStringFunction implements FREFunction {
    @Override
    String methodName() {
        return "setAuthKey";
    }
}
