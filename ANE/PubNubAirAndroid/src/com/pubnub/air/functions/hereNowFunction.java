package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class hereNowFunction extends SimpleCallbackFunction implements FREFunction {
    @Override
    String methodName() {
        return "hereNow";
    }
}
