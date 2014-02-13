package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;

    import flexunit.framework.Assert;

    public class TestHeartbeatInterval extends EventDispatcher {
        public var p:PubNub;
        public var channel:String;

        [Before]
        public function setUp():void {
            p = new PubNub(TestHelper.demoConfig);
            channel = TestHelper.generateChannel();
        }

        [Test(description="Should be able to set and get heartbeat interval")]
        public function testGetAndSetHeartbeatInterval():void {
            var interval:Number = 117;

            p.set_heartbeat_interval(interval);
            Assert.assertEquals(interval, p.get_heartbeat_interval());
        }
    }
}
