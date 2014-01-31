package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;
    import flash.utils.setTimeout;

    import flexunit.framework.Assert;

    import org.flexunit.async.Async;

    public class TestHistory extends EventDispatcher {
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

        [Test(async, timeout=10000, description="Should return 3 messages when 3 messages were published on channel")]
        public function testHistory():void {
            var historyHandler:Function;

            historyHandler = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertEquals(3, event.result[0].length);
            };

            resultFunction = Async.asyncHandler(this, historyHandler, 8000);
            addEventListener(PubNubEvent.HISTORY_RESULT_1, resultFunction);

            p.publish({
                channel: channel,
                message: messageString,
                callback: function (response:Array):void {
                    Assert.assertEquals(1, response[0]);
                    p.publish({
                        channel: channel,
                        message: messageString,
                        callback: function (response:Array):void {
                            Assert.assertEquals(1, response[0]);
                            p.publish({
                                channel: channel,
                                message: messageString,
                                callback: function (response:Array):void {
                                    Assert.assertEquals(1, response[0]);
                                    setTimeout(function ():void {
                                        p.history({
                                            channel: channel,
                                            callback: function (response:Array):void {
                                                dispatchEvent(new PubNubEvent(PubNubEvent.HISTORY_RESULT_1, response));
                                            }
                                        });
                                    }, 5000);
                                }
                            });
                        }
                    });
                }
            })
        }

        [Test(async, timeout=8000, description="Should return 2 messages when 3 were published and count is 2")]
        public function testHistoryWithCount2():void {
            var historyHandler:Function;

            historyHandler = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertEquals(2, event.result[0].length);
            };

            resultFunction = Async.asyncHandler(this, historyHandler, 8000);
            addEventListener(PubNubEvent.HISTORY_RESULT_1, resultFunction);

            p.publish({
                channel: channel,
                message: messageString,
                callback: function (response:Array):void {
                    Assert.assertEquals(1, response[0]);
                    p.publish({
                        channel: channel,
                        message: messageString,
                        callback: function (response:Array):void {
                            Assert.assertEquals(1, response[0]);
                            p.publish({
                                channel: channel,
                                message: messageString,
                                callback: function (response:Array):void {
                                    Assert.assertEquals(1, response[0]);
                                    setTimeout(function ():void {
                                        p.history({
                                            channel: channel,
                                            count: 2,
                                            callback: function (response:Array):void {
                                                dispatchEvent(new PubNubEvent(PubNubEvent.HISTORY_RESULT_1, response));
                                            }
                                        });
                                    }, 5000);
                                }
                            });
                        }
                    });
                }
            })
        }
    }
}
