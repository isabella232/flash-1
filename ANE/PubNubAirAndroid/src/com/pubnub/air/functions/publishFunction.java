package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class publishFunction extends SimpleCallbackFunction implements FREFunction {
    @Override
    String methodName() {
        return "publish";
    }
}
