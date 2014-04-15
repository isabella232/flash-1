package com.pubnub.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.pubnub.air.InstancesContainer;
import com.pubnub.air.PubNubWrapper;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public abstract class SynchronousGetIntFunction implements FREFunction {
    abstract String methodName();

    public FREObject call(FREContext ctx, FREObject[] passedArgs) {
        String instanceId;
        FREObject responseObject = null;
        Integer response;

        try {
            instanceId = passedArgs[0].getAsString();

            Method method;
            PubNubWrapper instance = InstancesContainer.getInstance(instanceId);

            method = instance.getClass().getMethod(methodName());
            response = (Integer) method.invoke(instance);
            responseObject = FREObject.newObject(response);
        } catch (InvocationTargetException e) {
            e.printStackTrace();
            ctx.dispatchStatusEventAsync("ERROR", e.getCause().getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            ctx.dispatchStatusEventAsync("ERROR", e.getMessage());
        }

        return responseObject;
    }
}
