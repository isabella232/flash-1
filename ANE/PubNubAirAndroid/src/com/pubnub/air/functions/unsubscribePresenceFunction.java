package com.pubnub.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.pubnub.air.InstancesContainer;

public class unsubscribePresenceFunction implements FREFunction {
    public FREObject call(FREContext ctx, FREObject[] passedArgs) {
        String instanceId;
        String channel;

        try {
            instanceId = passedArgs[0].getAsString();
            channel = passedArgs[1].getAsString();
            InstancesContainer.getInstance(instanceId).unsubscribePresence(channel);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.dispatchStatusEventAsync("ERROR", e.getMessage());
        }

        return null;
    }
}
