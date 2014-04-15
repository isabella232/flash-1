package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class unsubscribeFunction extends SynchronousSetStringFunction implements FREFunction {
    @Override
    String methodName() {
        return "unsubscribe";
    }
}
