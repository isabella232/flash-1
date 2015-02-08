package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;

    import flexunit.framework.Assert;

    import org.flexunit.async.Async;

    public class TestPublish extends EventDispatcher {
        public var p:PubNub;
        public var channel:String;
        public var messageString:String;

        [Before(async)]
        public function setUp():void {
            p = new PubNub(TestHelper.demoConfig);
            channel = TestHelper.generateChannel();
            messageString = 'Hi from ActionScript';
        }

        [Test(async, timeout=4000, description="Should publish string message without errors")]
        public function testPublishString():void {
            var message:String = "Hi from ActionScript";
            var subscribeMessageHandler:Function;
            var subscribeMessageFunction:Function;
            var publishHandler:Function;
            var publishFunction:Function;

            publishHandler = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertEquals(1, event.result[0]);
                Assert.assertEquals('Sent', event.result[1]);
                Assert.assertTrue(parseInt(event.result[2]) > 0);
            };

            subscribeMessageHandler = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertEquals(message, event.result[0]);
                Assert.assertEquals(channel, event.result[2]);
            };

            publishFunction = Async.asyncHandler(this, publishHandler, 4000);
            subscribeMessageFunction = Async.asyncHandler(this, subscribeMessageHandler, 4000);

            addEventListener(PubNubEvent.PUBLISH_RESULT, publishFunction);
            addEventListener(PubNubEvent.SUBSCRIBE_RESULT, subscribeMessageFunction);

            p.subscribe({
                channel: channel,
                message: function (message:Object, envelope:Object, channel:String, time:Number):void {
                    dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, arguments));
                    p.unsubscribe({channel: channel});
                },
                connect: function (channel:String):void {
                    p.publish({
                        channel: channel,
                        message: message
                    }, function (result:Object):void {
                        dispatchEvent(new PubNubEvent(PubNubEvent.PUBLISH_RESULT, result));
                    });
                }
            });
        }

        [Test(async, timeout=4000, description="Should publish JSON message without errors")]
        public function testPublishJSON():void {
            var message:Object = {some: {complex: 'json', object: 2}};
            var subscribeMessageHandler:Function;
            var subscribeMessageFunction:Function;
            var publishHandler:Function;
            var publishFunction:Function;

            publishHandler = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertEquals(1, event.result[0]);
                Assert.assertEquals('Sent', event.result[1]);
                Assert.assertTrue(parseInt(event.result[2]) > 0);
            };

            subscribeMessageHandler = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertObjectEquals(message, event.result[0]);
                Assert.assertTrue(event.result[1] is Array);
                Assert.assertEquals(channel, event.result[2]);
            };

            publishFunction = Async.asyncHandler(this, publishHandler, 4000);
            subscribeMessageFunction = Async.asyncHandler(this, subscribeMessageHandler, 4000);

            addEventListener(PubNubEvent.PUBLISH_RESULT, publishFunction);
            addEventListener(PubNubEvent.SUBSCRIBE_RESULT, subscribeMessageFunction);

            p.subscribe({
                channel: channel,
                message: function (message:Object, envelope:Object, channel:String, time:Number):void {
                    dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, arguments));
                    p.unsubscribe({channel: channel});
                },
                connect: function (channel:String):void {
                    p.publish({
                        channel: channel,
                        message: message
                    }, function (result:Object):void {
                        dispatchEvent(new PubNubEvent(PubNubEvent.PUBLISH_RESULT, result));
                    });
                }
            });
        }

        [Test(async, timeout=4000, description="Should publish JSON Array message without errors")]
        public function testPublishJSONArray():void {
            var message:Object = ['message', 'Hi from ActionScript'];
            var subscribeMessageHandler:Function;
            var subscribeMessageFunction:Function;
            var publishHandler:Function;
            var publishFunction:Function;

            publishHandler = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertEquals(1, event.result[0]);
                Assert.assertEquals('Sent', event.result[1]);
                Assert.assertTrue(parseInt(event.result[2]) > 0);
            };

            subscribeMessageHandler = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertObjectEquals(message, event.result[0]);
                Assert.assertTrue(event.result[1] is Array);
                Assert.assertEquals(channel, event.result[2]);
            };

            publishFunction = Async.asyncHandler(this, publishHandler, 4000);
            subscribeMessageFunction = Async.asyncHandler(this, subscribeMessageHandler, 4000);

            addEventListener(PubNubEvent.PUBLISH_RESULT, publishFunction);
            addEventListener(PubNubEvent.SUBSCRIBE_RESULT, subscribeMessageFunction);

            p.subscribe({
                channel: channel,
                message: function (message:Object, envelope:Object, channel:String, time:Number):void {
                    dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, arguments));
                    p.unsubscribe({channel: channel});
                },
                connect: function (channel:String):void {
                    p.publish({
                        channel: channel,
                        message: message
                    }, function (result:Object):void {
                        dispatchEvent(new PubNubEvent(PubNubEvent.PUBLISH_RESULT, result));
                    });
                }
            });
        }

        [Test(async, timeout=7000, description="Should publish multiple messages on multiple channels without failure")]
        public function testMultiplePublish():void {
            var subscribeHandler:Function;
            var subscribeFunctions:Array = [];
            var currentChannel:String;
            var currentMessage:Array;
            var num:int = 8;
            var i:int;

            subscribeHandler = function (event:PubNubEvent, message:Array):void {
                Assert.assertTrue(event.result is Array);
                Assert.assertObjectEquals(message, event.result);
            };

            for (i = 0; i < num; i++) {
                currentChannel = channel + '-array-' + i;
                currentMessage = [messageString, currentChannel];

                subscribeFunctions[i] = Async.asyncHandler(this, subscribeHandler, 5000, currentMessage);

                p.subscribe({
                    channel: currentChannel,
                    message: (function (channel:String, index:int):Function {
                        return function (result:Object, envelope:Object, channelOrGroup:String, time:Number, channel:String):void {
                            dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT + index, result));
                            p.unsubscribe({channel: channel});
                        }
                    })(currentChannel, i),
                    connect: (function (channel:String, message:Array, index:int):Function {
                        return function (channel:String):void {
                            p.publish({
                                channel: channel,
                                message: message
                            });
                        }
                    })(currentChannel, currentMessage, i)
                });

                addEventListener(PubNubEvent.SUBSCRIBE_RESULT + i, subscribeFunctions[i]);
            }
        }
    }
}
