package com.pubnub.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.pubnub.air.ExtendedCallback;
import com.pubnub.air.InstancesContainer;
import org.json.JSONObject;

public class subscribeFunction implements FREFunction {
    public FREObject call(FREContext ctx, FREObject[] passedArgs) {
        String jsonString;
        String instanceId;
        JSONObject config;
        String callback;
        String error;
        String connect;
        String disconnect;
        String reconnect;

        final ExtendedCallback cb;

        try {
            jsonString = passedArgs[1].getAsString();
            instanceId = passedArgs[0].getAsString();

            config = new JSONObject(jsonString);

            callback = config.getString("callback");
            error = config.getString("error");
            connect = config.getString("connect");
            disconnect = config.getString("disconnect");
            reconnect = config.getString("reconnect");

            callback = (callback.equals("null")) ? null : callback;
            error = (error.equals("null")) ? null : error;
            connect = (connect.equals("null")) ? null : connect;
            disconnect = (disconnect.equals("null")) ? null : disconnect;
            reconnect = (reconnect.equals("null")) ? null : reconnect;

            cb = new ExtendedCallback(ctx, instanceId, callback, error, connect, disconnect, reconnect);

            InstancesContainer.getInstance(instanceId).subscribe(config, cb);
        } catch (Exception e) {
            e.printStackTrace();
            ctx.dispatchStatusEventAsync("ERROR", e.getMessage());
        }

        return null;
    }
}
