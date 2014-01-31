package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;

    import flexunit.framework.Assert;

    import org.flexunit.async.Async;

    public class TestSubscribe extends EventDispatcher {
        public var p:PubNub;
        public var channel:String;
        public var messageString:String;

        [Before(async)]
        public function setUp():void {
            p = new PubNub(TestHelper.demoConfig);
            channel = TestHelper.generateChannel();
            messageString = 'Hi from ActionScript';
        }

        [Test(async, timeout=4000, description="Should invoke connect callback")]
        public function testSubscribeConnected():void {
            var connectedFunction:Function;

            connectedFunction = Async.asyncHandler(this, handleConnected, 4000, channel);
            addEventListener(PubNubEvent.SUBSCRIBE_RESULT, connectedFunction);

            p.subscribe({
                channel: channel,
                message: function subscribeMessageHandler(message:Object, envelope:Object, channel:String, time:Number):void {
                },
                connect: function subscribeConnectHandler(message:Object):void {
                    dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, message));
                    p.unsubscribe({channel: channel});
                }
            });
        }

        private function handleConnected(event:PubNubEvent, channel:String):void {
            Assert.assertEquals(channel, event.result);
        }
    }
}
