package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class setOriginFunction extends SynchronousSetStringFunction implements FREFunction {
    @Override
    String methodName() {
        return "setOrigin";
    }
}
