package com.pubnub.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.pubnub.air.InstancesContainer;
import com.pubnub.air.PubNubWrapper;
import com.pubnub.air.SimpleCallback;
import org.json.JSONObject;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public abstract class SimpleCallbackFunction implements FREFunction {
    abstract String methodName();

    public FREObject call(FREContext ctx, FREObject[] passedArgs) {
        String jsonString;
        String instanceId;
        JSONObject config;
        String callback;
        String error;
        Method method;

        final SimpleCallback cb;

        try {
            jsonString = passedArgs[1].getAsString();
            instanceId = passedArgs[0].getAsString();

            config = new JSONObject(jsonString);

            callback = config.getString("callback");
            error = config.getString("error");

            callback = (callback.equals("null")) ? null : callback;
            error = (error.equals("null")) ? null : error;

            cb = new SimpleCallback(ctx, instanceId, callback, error);

            PubNubWrapper instance = InstancesContainer.getInstance(instanceId);

            method = instance.getClass().getMethod(methodName(), JSONObject.class, SimpleCallback.class);
            method.invoke(instance, config, cb);
        } catch (InvocationTargetException e) {
            e.printStackTrace();
            ctx.dispatchStatusEventAsync("ERROR", e.getCause().getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            ctx.dispatchStatusEventAsync("ERROR", e.getMessage());
        }

        return null;
    }
}
