package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class whereNowFunction extends SimpleCallbackFunction implements FREFunction {
    @Override
    String methodName() {
        return "whereNow";
    }
}
