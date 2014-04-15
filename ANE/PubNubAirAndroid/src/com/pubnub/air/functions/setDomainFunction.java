package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class setDomainFunction extends SynchronousSetStringFunction implements FREFunction {
    @Override
    String methodName() {
        return "setDomain";
    }
}
