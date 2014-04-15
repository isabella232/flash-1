package com.pubnub.air;

import java.util.HashMap;
import java.util.Map;

public class InstancesContainer {
    public static Map<String, PubNubWrapper> instancesMap;

    static {
        instancesMap = new HashMap<String, PubNubWrapper>();
    }

    public static void addInstance(String key, PubNubWrapper instance) {
        instancesMap.put(key, instance);
    }

    public static PubNubWrapper getInstance(String key) {
        return instancesMap.get(key);
    }
}
