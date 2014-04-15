package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class setUUIDFunction extends SynchronousSetStringFunction implements FREFunction {
    @Override
    String methodName() {
        return "setUUID";
    }
}
