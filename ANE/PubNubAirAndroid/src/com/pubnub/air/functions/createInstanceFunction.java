package com.pubnub.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.pubnub.air.InstancesContainer;
import com.pubnub.air.PubNubWrapper;
import org.json.JSONObject;

public class createInstanceFunction implements FREFunction {

    public FREObject call(FREContext ctx, FREObject[] passedArgs) {
        String instanceId;
        String setupString;
        JSONObject setup;

        try {
            instanceId = passedArgs[0].getAsString();
            setupString = passedArgs[1].getAsString();

            setup = new JSONObject(setupString);

            PubNubWrapper pubnub = new PubNubWrapper(instanceId, setup);
            InstancesContainer.addInstance(instanceId, pubnub);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}
