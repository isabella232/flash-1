package com.pubnub.air;

import com.adobe.fre.FREContext;
import com.pubnub.api.Callback;
import com.pubnub.api.PubnubError;

public class SimpleCallback extends Callback {

    private FREContext ctx;
    private String instanceId;
    private String successCallbackId;
    private String errorCallbackId;

    public SimpleCallback(FREContext ctx, String instanceId, String successCallbackId, String errorCallbackId) {
        this.ctx = ctx;
        this.instanceId = instanceId;
        this.successCallbackId = successCallbackId;
        this.errorCallbackId = errorCallbackId;
    }

    @Override
    public void successCallback(String s, Object o) {
        String res = o.toString();

        this.ctx.dispatchStatusEventAsync(instanceId + "/CALLBACK/" + successCallbackId, res);
    }

    @Override
    public void errorCallback(String s, PubnubError pubnubError) {
        super.errorCallback(s, pubnubError);

        if (errorCallbackId != null) {
            String res = pubnubError.toString();
            this.ctx.dispatchStatusEventAsync(instanceId + "/CALLBACK/" + errorCallbackId, res);
        }
    }
}
