package com.pubnub.air;

import com.adobe.fre.FREContext;
import com.pubnub.api.Callback;
import com.pubnub.api.PubnubError;

public class ExtendedCallback extends Callback {
    private FREContext ctx;
    private String instanceId;
    private String successCallbackId;
    private String errorCallbackId;
    private String connectCallbackId;
    private String disconnectCallbackId;
    private String reconnectCallbackId;

    public ExtendedCallback(FREContext ctx,
                            String instanceId,
                            String successCallbackId,
                            String errorCallbackId,
                            String connectCallbackId,
                            String disconnectCallbackId,
                            String reconnectCallbackId) {
        this.ctx = ctx;
        this.instanceId = instanceId;
        this.successCallbackId = successCallbackId;
        this.errorCallbackId = errorCallbackId;
        this.connectCallbackId = connectCallbackId;
        this.disconnectCallbackId = disconnectCallbackId;
        this.reconnectCallbackId = reconnectCallbackId;
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

    @Override
    public void connectCallback(String s, Object o) {
        super.connectCallback(s, o);

        if (connectCallbackId != null) {
            String res = o.toString();
            this.ctx.dispatchStatusEventAsync(instanceId + "/CALLBACK/" + connectCallbackId, res);
        }
    }

    @Override
    public void disconnectCallback(String s, Object o) {
        super.disconnectCallback(s, o);

        if (disconnectCallbackId != null) {
            String res = o.toString();
            this.ctx.dispatchStatusEventAsync(instanceId + "/CALLBACK/" + disconnectCallbackId, res);
        }
    }

    @Override
    public void reconnectCallback(String s, Object o) {
        super.reconnectCallback(s, o);

        if (reconnectCallbackId != null) {
            String res = o.toString();
            this.ctx.dispatchStatusEventAsync(instanceId + "/CALLBACK/" + reconnectCallbackId, res);
        }
    }
}
