package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;

    import flexunit.framework.Assert;

    public class TestHeartbeat extends EventDispatcher {
        public var p:PubNub;
        public var channel:String;

        [Before]
        public function setUp():void {
            p = new PubNub(TestHelper.demoConfig);
            channel = TestHelper.generateChannel();
        }

        [Test(description="Should be able to set and get heartbeat interval")]
        public function testGetAndSetHeartbeatInterval():void {
            var interval:Number = 10;

            p.set_heartbeat(interval);
            Assert.assertEquals(interval, p.get_heartbeat());
        }

        [Test(description="Should be able to set and get heartbeat interval using subscribe method")]
        public function testSettingHeartbeatInSubscribe():void {
            p.set_heartbeat(8);

            Assert.assertEquals(8, p.get_heartbeat());

            p.subscribe({
                channel: channel,
                message: function ():void {
                }
            });

            Assert.assertEquals(8, p.get_heartbeat());

            p.subscribe({
                channel: channel + '1',
                message: function ():void {
                },
                heartbeat: 1
            });

            Assert.assertEquals(8, p.get_heartbeat());

            p.subscribe({
                channel: channel + '1',
                message: function ():void {
                },
                heartbeat: 7
            });

            Assert.assertEquals(7, p.get_heartbeat());

            p.subscribe({
                channel: channel + '1',
                message: function ():void {
                },
                heartbeat: 0
            });

            Assert.assertEquals(0, p.get_heartbeat());
        }
    }
}
