package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;
    import flash.utils.setTimeout;

    import flexunit.framework.Assert;

    import org.flexunit.async.Async;

    public class TestHereNow extends EventDispatcher {
        public var p:PubNub;
        public var channel:String;
        public var messageString:String;
        public var resultFunction:Function;

        [Before(async)]
        public function setUp():void {
            p = new PubNub(TestHelper.demoConfig);
            channel = TestHelper.generateChannel();
            messageString = 'Hi from ActionScript';
        }

        [Test(async, timeout=20000, description="Should show occupancy of channel")]
        public function testHereNow():void {
            resultFunction = Async.asyncHandler(this, handleHereNowResult, 20000);
            addEventListener(PubNubEvent.HERE_NOW_RESULT, resultFunction);

            p.subscribe({
                channel: channel,
                message: function subscribeMessageHandler(message:Object, envelope:Object, channel:String, time:Number):void {
                },
                connect: function subscribeConnectHandler(channel:String):void {
                    setTimeout(function ():void {
                        p.here_now({
                            channel: channel,
                            callback: function (message:Object):void {
                                dispatchEvent(new PubNubEvent(PubNubEvent.HERE_NOW_RESULT, message));
                                p.unsubscribe({channel: channel});
                            }
                        });
                    }, 15000);
                    p.publish({
                        channel: channel,
                        message: 'hi'
                    })
                }
            });
        }

        protected function handleHereNowResult(event:PubNubEvent, passThroughData:Object):void {
            Assert.assertEquals(1, event.result.occupancy);
        }
    }
}
