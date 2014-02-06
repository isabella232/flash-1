package applicationTest {
    public class TestHelper {
        private static var PUBLISH_KEY:String = "pub-c-a1c0e8f5-c7fc-4d8e-95aa-98e20d57519a";
        private static var SUBSCRIBE_KEY:String = "sub-c-939301c8-899b-11e3-96c6-02ee2ddab7fe";
        private static var SECRET_KEY:String = "sec-c-NjU5NTBmOWMtOGE5Zi00ZTA2LWIwZjgtOTIzNGMzMGQwZTE0";

        public static var pamConfig:Object = {
            origin: "pam-beta.pubnub.com",
            publish_key: PUBLISH_KEY,
            subscribe_key: SUBSCRIBE_KEY,
            secret_key: SECRET_KEY
        };

        public static var presenceConfig:Object = {
            origin: "presence-beta.pubnub.com",
            publish_key: 'demo',
            subscribe_key: 'demo',
            uuid: (new Date()).time
        };

        public static var demoConfig:Object = {
            origin: "pubsub.pubnub.com",
            publish_key: "demo",
            subscribe_key: "demo"
        };

        public function TestHelper() {

        }

        public static function generateChannel():String {
            return "flash_test_channel_" + (new Date()).time;
        }
    }
}
