package com.pubnub.air.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.pubnub.air.InstancesContainer;
import com.pubnub.air.PubNubWrapper;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public abstract class SynchronousSetIntFunction implements FREFunction {
    abstract String methodName();

    public FREObject call(FREContext ctx, FREObject[] passedArgs) {
        Integer val;
        String instanceId;

        try {
            val = passedArgs[1].getAsInt();
            instanceId = passedArgs[0].getAsString();

            PubNubWrapper instance = InstancesContainer.getInstance(instanceId);
            Method method;

            method = instance.getClass().getMethod(methodName(), int.class);
            method.invoke(instance, val);
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
