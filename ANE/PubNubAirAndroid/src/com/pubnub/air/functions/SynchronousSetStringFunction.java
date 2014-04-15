package com.pubnub.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.pubnub.air.InstancesContainer;
import com.pubnub.air.PubNubWrapper;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public abstract class SynchronousSetStringFunction implements FREFunction {
    abstract String methodName();

    public FREObject call(FREContext ctx, FREObject[] passedArgs) {
        String str;
        String instanceId;

        try {
            str = passedArgs[1].getAsString();
            instanceId = passedArgs[0].getAsString();

            PubNubWrapper instance = InstancesContainer.getInstance(instanceId);
            Method method;

            method = instance.getClass().getMethod(methodName(), String.class);
            method.invoke(instance, str);
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
