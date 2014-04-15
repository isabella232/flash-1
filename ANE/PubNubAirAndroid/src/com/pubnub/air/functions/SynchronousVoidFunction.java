package com.pubnub.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.pubnub.air.InstancesContainer;
import com.pubnub.air.PubNubWrapper;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public abstract class SynchronousVoidFunction implements FREFunction {
    abstract String methodName();

    public FREObject call(FREContext ctx, FREObject[] passedArgs) {
        String instanceId;

        try {
            instanceId = passedArgs[0].getAsString();

            Method method;
            PubNubWrapper instance = InstancesContainer.getInstance(instanceId);

            method = instance.getClass().getMethod(methodName());
            method.invoke(instance);
        } catch (InvocationTargetException e) {
            ctx.dispatchStatusEventAsync("ERROR", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            ctx.dispatchStatusEventAsync("ERROR", e.getMessage());
        }

        return null;
    }
}
