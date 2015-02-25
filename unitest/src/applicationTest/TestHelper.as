package applicationTest {
import com.pubnub.PubNub;

public class TestHelper {
        private static var PUBLISH_KEY:String = "pub-c-a1c0e8f5-c7fc-4d8e-95aa-98e20d57519a";
        private static var SUBSCRIBE_KEY:String = "sub-c-939301c8-899b-11e3-96c6-02ee2ddab7fe";
        private static var SECRET_KEY:String = "sec-c-NjU5NTBmOWMtOGE5Zi00ZTA2LWIwZjgtOTIzNGMzMGQwZTE0";

        public static var pamConfig:Object = {
            origin: "pubsub.pubnub.com",
            publish_key: PUBLISH_KEY,
            subscribe_key: SUBSCRIBE_KEY,
            secret_key: SECRET_KEY
        };

        public static var pamConfig36:Object = {
            origin: "pubsub.pubnub.com",
            publish_key: "demo-36",
            subscribe_key: "demo-36",
            secret_key: "demo-36"
        };

        public static var demoConfig:Object = {
            origin: "pubsub.pubnub.com",
            publish_key: "demo",
            subscribe_key: "demo",
            uuid: (new Date()).time
        };

        public function TestHelper() {

        }

        public static function generateChannel():String {
            return "flash_test_channel_" + (new Date()).time;
        }

        public static function generateChannelGroup():String {
            return "ftest_" + (new Date()).time;
        }

        public static function inListDeep(array:Array, obj:Object):Boolean {
            var isTrue:Boolean;

            for (var i:int = 0; i < array.length; i++) {
                if (JSON.stringify(array[i]) === JSON.stringify(obj)) {
                    isTrue = true;
                }
            }

            return isTrue;
        }

        public static function cleanup():void {
            var p:PubNub = new PubNub(pamConfig36);

            p.channel_group_list_namespaces({}, function blah(response:Object):void {
                var namespaces:Array = response.namespaces;

                for (var i:int = 0; i < namespaces.length; i++) {
                    if (namespaces[i].indexOf("ftest_") == 0) {
                        (function (nsp:String):void {
                            p.channel_group_remove_namespace({
                                namespace: nsp
                            });
                        })(namespaces[i]);
                    }
                }
            });

            p.channel_group_list_groups({}, function blah(response:Object):void {
                var groups:Array = response.groups;

                for (var i:int = 0; i < groups.length; i++) {
                    if (groups[i].indexOf("ftest_") == 0) {
                        (function (group:String):void {
                            p.channel_group_remove_group({
                                channel_group: group
                            });
                        })(groups[i]);
                    }
                }
            });
        }
    }
}
