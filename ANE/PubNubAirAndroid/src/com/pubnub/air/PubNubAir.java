package com.pubnub.air;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class PubNubAir implements FREExtension {
    public FREContext createContext(String extId) {
        return new PubNubAirContext();
    }

    public void dispose() {
    }

    public void initialize() {
    }
}
