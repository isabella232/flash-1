package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;
    import flash.utils.setTimeout;

    import flexunit.framework.Assert;

    import org.flexunit.async.Async;

    import org.hamcrest.assertThat;
    import org.hamcrest.collection.hasItems;

    public class TestWhereNow extends EventDispatcher {
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

        [Test(async, timeout=5000, description="#where_now() should return channel x in result for uuid y, when uuid y subscribed to channel x")]
        public function testHereNow():void {
            var subscribeConnectedHandler:Function;
            var subscribeConnectFunction:Function;

            subscribeConnectedHandler = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertEquals(channel, event.result);
            };

            subscribeConnectFunction = Async.asyncHandler(this, subscribeConnectedHandler, 4000);
            resultFunction = Async.asyncHandler(this, handleWhereNowResult, 40000);

            addEventListener(PubNubEvent.WHERE_NOW_RESULT + '_CONNECTED', subscribeConnectFunction);
            addEventListener(PubNubEvent.WHERE_NOW_RESULT, resultFunction);

            p.subscribe({
                channel: channel,
                connect: function (response:Object):void {
                    dispatchEvent(new PubNubEvent(PubNubEvent.WHERE_NOW_RESULT + '_CONNECTED', response));
                    setTimeout(function ():void {
                        p.where_now({
                            uuid: TestHelper.demoConfig.uuid,
                            callback: function (data:Object):void {
                                dispatchEvent(new PubNubEvent(PubNubEvent.WHERE_NOW_RESULT, data));
                            }
                        })
                    }, 1500);
                },
                callback: function (response:Object):void {
                }
            });
        }

        protected function handleWhereNowResult(event:PubNubEvent, passThroughData:Object):void {
            assertThat(event.result.channels, hasItems(channel));
            p.unsubscribe({channel: channel});
        }
    }
}
