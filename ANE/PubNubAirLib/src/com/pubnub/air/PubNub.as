package com.pubnub.air {
    import flash.events.EventDispatcher;
    import flash.events.StatusEvent;
    import flash.external.ExtensionContext;
    import flash.utils.ByteArray;
    import flash.utils.getQualifiedClassName;

    public class PubNub extends EventDispatcher {
        private static var extContext:ExtensionContext = null;
        private static var instances:Object = {};
        private var callbacks:Object;
        private var instanceId:String;

        public function PubNub(config:Object) {
            instanceId = PubNub.generateId();
            callbacks = {};

            if (!extContext) {
                extContext = ExtensionContext.createExtensionContext("com.pubnub.air", "PubNubAir");
                if (!extContext) {
                    throw new Error("Instance creation failed");
                }
            }

            instances[instanceId] = this;

            extContext.call("createInstance", instanceId, JSON.stringify(config), this);
            extContext.addEventListener(StatusEvent.STATUS, PubNub.statusHandler);
        }

        private static function statusHandler(e:StatusEvent):void {
            if (e.code === "ERROR") {
                throw new Error(e.level);
            }
            var codeArray:Array = e.code.split('/');

            // instanceId
            var iid:String = codeArray[0];
            // callbackId
            var cid:String = codeArray[2];
            var code:String = codeArray[1];

            switch (code) {
                case 'CALLBACK':
                    PubNub.getInstance(iid).executeCallback(cid, e.level);
                    break;
                default:
                    trace('UNHANDLED CALLBACK', e);
            }
        }

        private static function getInstance(iid:String):PubNub {
            return PubNub.instances[iid];
        }

        private function executeCallback(callbackId:String, result:String):void {
            var res:*;

            try {
                res = JSON.parse(result);
            } catch (e:Error) {
                res = result;
            }

            callbacks[callbackId](res);
        }

        public function publish(config:Object):void {
            config.message_type = PubNub.getTypeOf(config.message);

            var newArgs:Object = mockSimpleObjectCallbacks(config);
            extContext.call("publish", instanceId, JSON.stringify(newArgs));
        }

        public function subscribe(config:Object):void {
            var newArgs:Object = mockExtendedObjectCallbacks(config);
            extContext.call("subscribe", instanceId, JSON.stringify(newArgs));
        }

        public function history(config:Object):void {
            var newArgs:Object = mockSimpleObjectCallbacks(config);
            extContext.call("history", instanceId, JSON.stringify(newArgs));
        }

        public function unsubscribe(channel:String):void {
            extContext.call("unsubscribe", instanceId, channel);
        }

        public function unsubscribe_all():void {
            extContext.call("unsubscribeAll", instanceId);
        }

        public function time(config:Object):void {
            var newArgs:Object = mockExtendedObjectCallbacks(config);
            extContext.call("time", instanceId, newArgs.callback, newArgs.error);
        }

        public function get_domain():String {
            return extContext.call("getDomain", instanceId) as String;
        }

        public function set_domain(domain:String):void {
            extContext.call("setDomain", instanceId, domain);
        }

        public function get_origin():String {
            return extContext.call("getOrigin", instanceId) as String;
        }

        public function set_origin(origin:String):void {
            extContext.call("setOrigin", instanceId, origin);
        }

        public function get_non_subscribe_timeout():int {
            return extContext.call("getNonSubscribeTimeout", instanceId) as int;
        }

        public function set_non_subscribe_timeout(timeout:int):void {
            extContext.call("setNonSubscribeTimeout", instanceId, timeout);
        }

        public function get_auth_key():String {
            return extContext.call("getAuthKey", instanceId) as String;
        }

        public function set_auth_key(auth_key:String):void {
            extContext.call("setAuthKey", instanceId, auth_key);
        }

        public function unset_auth_key():void {
            extContext.call("unsetAuthKey", instanceId);
        }

        public function presence(config:Object):void {
            var newArgs:Object = mockExtendedObjectCallbacks(config);
            extContext.call("presence", instanceId, JSON.stringify(newArgs));
        }

        public function here_now(config:Object):void {
            var newArgs:Object = mockSimpleObjectCallbacks(config);
            extContext.call("hereNow", instanceId, JSON.stringify(newArgs));
        }

        public function where_now(config:Object):void {
            var newArgs:Object = mockSimpleObjectCallbacks(config);
            extContext.call("whereNow", instanceId, JSON.stringify(newArgs));
        }

        public function set_heartbeat(heartbeat:int):void {
            extContext.call("setHeartbeat", instanceId, heartbeat);
        }

        public function get_heartbeat():int {
            return extContext.call("getHeartbeat", instanceId) as int;
        }

        public function unsubscribe_presence(channel:String):void {
            extContext.call("unsubscribePresence", instanceId, channel);
        }

        public function shutdown():void {
            extContext.call("shutdown", instanceId);
        }

        public function uuid():String {
            return extContext.call("uuid", instanceId) as String;
        }

        public function getUUID():String {
            return extContext.call("getUUID", instanceId) as String;
        }

        public function setUUID(uuid:String):void {
            extContext.call("setUUID", instanceId, uuid);
        }

        private static function getTypeOf(message:*):String {
            if (message is int) {
                return 'integer';
            } else {
                return getQualifiedClassName(message).toLowerCase();
            }
        }

        private function mockSimpleObjectCallbacks(obj:Object):Object {
            var newObject:Object = cloneObject(obj);

            newObject.callback = mockCallback(obj.callback);
            newObject.error = mockCallback(obj.error);

            return newObject;
        }

        private function mockExtendedObjectCallbacks(obj:Object):Object {
            var newObject:Object = cloneObject(obj);

            newObject.callback = mockCallback(obj.callback);
            newObject.error = mockCallback(obj.error);
            newObject.connect = mockCallback(obj.connect);
            newObject.disconnect = mockCallback(obj.disconnect);
            newObject.reconnect = mockCallback(obj.reconnect);

            return newObject;
        }

        private function mockCallback(callback:Function = null):String {
            if (null === callback) return null;
            var id:String = PubNub.generateId();
            callbacks[id] = callback;
            return id;
        }

        private static function generateId():String {
            return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g,
                    function (c:String, ...args):String {
                        var r:int = Math.random() * 16 | 0,
                                v:int = c == 'x' ? r : (r & 0x3 | 0x8);
                        return v.toString(16);
                    });
        }

        private static function cloneObject(source:Object):Object {
            var newBA:ByteArray = new ByteArray();
            newBA.writeObject(source);
            newBA.position = 0;
            return (newBA.readObject());
        }
    }
}