package com.pubnub.air;

import com.pubnub.api.Pubnub;
import com.pubnub.api.PubnubException;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class PubNubWrapper {
    public String instanceId;
    private Pubnub pubnub;

    private enum MessageType {
        array, object, string, number, integer
    }

    public PubNubWrapper(String instanceId, JSONObject setup) {
        this.instanceId = instanceId;

        String publish_key;
        String subscribe_key;
        String secret_key;
        String cipher_key;
        Boolean ssl;
        String iv;

        try {
            publish_key = setup.getString("publish_key");
        } catch (JSONException e) {
            publish_key = "demo";
        }

        try {
            subscribe_key = setup.getString("subscribe_key");
        } catch (JSONException e) {
            subscribe_key = "demo";
        }

        try {
            secret_key = setup.getString("secret_key");
        } catch (JSONException e) {
            secret_key = "";
        }

        try {
            cipher_key = setup.getString("cipher_key");
        } catch (JSONException e) {
            cipher_key = "";
        }

        try {
            ssl = setup.getBoolean("ssl");
        } catch (JSONException e) {
            ssl = false;
        }

        try {
            iv = setup.getString("iv");
        } catch (JSONException e) {
            iv = null;
        }

        this.pubnub = new Pubnub(publish_key, subscribe_key, secret_key, cipher_key, ssl, iv);
    }

    public void history(JSONObject config, SimpleCallback cb) throws JSONException {
        String channel;
        Long start;
        Long end;
        Integer count;
        Boolean reverse;

        channel = config.getString("channel");

        try {
            start = config.getLong("start");
        } catch (JSONException e) {
            start = null;
        }

        try {
            end = config.getLong("end");
        } catch (JSONException e) {
            end = null;
        }

        try {
            count = config.getInt("count");
        } catch (JSONException e) {
            count = null;
        }
        try {
            reverse = config.getBoolean("reverse");
        } catch (JSONException e) {
            reverse = null;
        }

        if (start != null && end != null && count != null) {
            this.pubnub.history(channel, start, end, count, cb);
        } else if (start != null && count != null && reverse != null) {
            this.pubnub.history(channel, start, count, reverse, cb);
        } else if (start != null && count != null) {
            this.pubnub.history(channel, start, count, cb);
        } else if (start != null && reverse != null) {
            this.pubnub.history(channel, start, reverse, cb);
        } else if (count != null && reverse != null) {
            this.pubnub.history(channel, count, reverse, cb);
        } else if (start != null && end != null) {
            this.pubnub.history(channel, start, end, cb);
        } else if (reverse != null) {
            this.pubnub.history(channel, reverse, cb);
        } else if (count != null) {
            this.pubnub.history(channel, count, cb);
        }
    }

    public void publish(JSONObject config, SimpleCallback cb) throws JSONException {
        String channel;
        String message;
        String messageObjectType = null;

        channel = config.getString("channel");
        messageObjectType = config.getString("message_type");
        message = config.getString("message");


        MessageType messageType = MessageType.valueOf(messageObjectType);

        switch (messageType) {
            case array:
                JSONArray messageArray = new JSONArray(message);
                this.pubnub.publish(channel, messageArray, cb);
                break;
            case object:
                JSONObject messageObject = new JSONObject(message);
                this.pubnub.publish(channel, messageObject, cb);
                break;
            case integer:
                Integer messageInteger = config.getInt("message");
                this.pubnub.publish(channel, messageInteger, cb);
                break;
            case number:
                Double messageDouble = config.getDouble("message");
                this.pubnub.publish(channel, messageDouble, cb);
                break;
            case string:
                this.pubnub.publish(channel, message, cb);
                break;
        }
    }

    public void subscribe(JSONObject config, ExtendedCallback cb) throws JSONException, PubnubException {
        String channel;

        channel = config.getString("channel");

        this.pubnub.subscribe(channel, cb);
    }

    public void presence(JSONObject config, ExtendedCallback cb) throws JSONException, PubnubException {
        String channel;

        channel = config.getString("channel");

        this.pubnub.presence(channel, cb);
    }

    public void hereNow(JSONObject config, SimpleCallback cb) {
        String channel;
        Boolean state;
        Boolean disable_uuids;

        try {
            channel = config.getString("channel");
        } catch (JSONException e) {
            channel = null;
        }

        try {
            state = config.getBoolean("state");
        } catch (JSONException e) {
            state = false;
        }

        try {
            disable_uuids = config.getBoolean("uuids");
        } catch (JSONException e) {
            disable_uuids = false;
        }

        this.pubnub.hereNow(channel, state, disable_uuids, cb);
    }

    public void whereNow(JSONObject config, SimpleCallback cb) {
        String uuid;

        try {
            uuid = config.getString("uuid");
        } catch (JSONException e) {
            uuid = null;
        }

        if (uuid != null) {
            this.pubnub.whereNow(uuid, cb);
        } else {
            this.pubnub.whereNow(cb);
        }
    }

    public void time(SimpleCallback cb) {
        this.pubnub.time(cb);
    }

    public String getAuthKey() {
        return this.pubnub.getAuthKey();
    }

    public void setAuthKey(String key) {
        this.pubnub.setAuthKey(key);
    }

    public void unsetAuthKey() {
        this.pubnub.unsetAuthKey();
    }

    public String getDomain() {
        return this.pubnub.getDomain();
    }

    public void setDomain(String domain) {
        this.pubnub.setDomain(domain);
    }

    public String getOrigin() {
        return this.pubnub.getOrigin();
    }

    public void setOrigin(String origin) {
        this.pubnub.setOrigin(origin);
    }

    public int getNonSubscribeTimeout() {
        return this.pubnub.getNonSubscribeTimeout();
    }

    public void setNonSubscribeTimeout(int timeout) {
        this.pubnub.setNonSubscribeTimeout(timeout);
    }

    public String uuid() {
        return this.pubnub.uuid();
    }

    public String getUUID() {
        return this.pubnub.getUUID();
    }

    public void setUUID(String uuid) {
        this.pubnub.setUUID(uuid);
    }

    public int getHeartbeat() {
        return this.pubnub.getHeartbeat();
    }

    public void setHeartbeat(int heartbeat) {
        this.pubnub.setHeartbeat(heartbeat);
    }

    public void unsubscribe(String channel) {
        this.pubnub.unsubscribe(channel);
    }

    public void unsubscribeAll() {
        this.pubnub.unsubscribeAll();
    }

    public void unsubscribePresence(String channel) {
        this.pubnub.unsubscribePresence(channel);
    }

    public void shutdown() {
        this.pubnub.shutdown();
    }
}
