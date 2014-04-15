package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class historyFunction extends SimpleCallbackFunction implements FREFunction {
    @Override
    String methodName() {
        return "history";
    }
}
