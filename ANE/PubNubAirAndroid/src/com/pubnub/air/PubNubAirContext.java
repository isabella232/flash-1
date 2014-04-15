package com.pubnub.air;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.pubnub.air.functions.*;

import java.util.HashMap;
import java.util.Map;

public class PubNubAirContext extends FREContext {
    @Override
    public void dispose() {
    }

    @Override
    public Map<String, FREFunction> getFunctions() {

        Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();

        functionMap.put("createInstance", new createInstanceFunction());
        functionMap.put("publish", new publishFunction());
        functionMap.put("subscribe", new subscribeFunction());
        functionMap.put("uuid", new uuidFunction());
        functionMap.put("history", new historyFunction());
        functionMap.put("unsubscribe", new unsubscribeFunction());
        functionMap.put("unsubscribeAll", new unsubscribeAllFunction());
        functionMap.put("shutdown", new shutdownFunction());

        functionMap.put("presence", new presenceFunction());
        functionMap.put("hereNow", new hereNowFunction());
        functionMap.put("whereNow", new whereNowFunction());
        functionMap.put("setHeartbeat", new setHeartbeatFunction());
        functionMap.put("getHeartbeat", new getHeartbeatFunction());
        functionMap.put("unsubscribePresence", new unsubscribePresenceFunction());

        functionMap.put("uuid", new uuidFunction());
        functionMap.put("getUUID", new getUUIDFunction());
        functionMap.put("setUUID", new setUUIDFunction());

        functionMap.put("getAuthKey", new getAuthKeyFunction());
        functionMap.put("setAuthKey", new setAuthKeyFunction());
        functionMap.put("unsetAuthKey", new unsetAuthKeyFunction());

        functionMap.put("getDomain", new getDomainFunction());
        functionMap.put("setDomain", new setDomainFunction());
        functionMap.put("getOrigin", new getOriginFunction());
        functionMap.put("setOrigin", new setOriginFunction());
        functionMap.put("getNonSubscribeTimeout", new getNonSubscribeTimeoutFunction());
        functionMap.put("setNonSubscribeTimeout", new setNonSubscribeTimeoutFunction());

        return functionMap;
    }
}
