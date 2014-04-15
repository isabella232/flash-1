package com.pubnub.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.pubnub.air.InstancesContainer;
import com.pubnub.air.SimpleCallback;

public class timeFunction implements FREFunction {
    public FREObject call(FREContext ctx, FREObject[] passedArgs) {
        String callback;
        String error;
        String instanceId;

        final SimpleCallback cb;

        try {
            callback = passedArgs[1].getAsString();
            error = passedArgs[2].getAsString();

            callback = (callback.equals("null")) ? null : callback;
            error = (error.equals("null")) ? null : error;

            instanceId = passedArgs[0].getAsString();
            cb = new SimpleCallback(ctx, instanceId, callback, error);

            InstancesContainer.getInstance(instanceId).time(cb);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.dispatchStatusEventAsync("ERROR", e.getMessage());
        }

        return null;
    }
}
