package com.pubnub.air.functions;

import com.adobe.fre.FREFunction;

public class unsubscribeAllFunction extends SynchronousVoidFunction implements FREFunction {
    @Override
    String methodName() {
        return "unsubscribeAll";
    }
}
