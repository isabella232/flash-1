package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;
    import flash.utils.setTimeout;

    import flexunit.framework.Assert;

    import org.flexunit.async.Async;

    import org.hamcrest.assertThat;
    import org.hamcrest.collection.hasItems;

    public class TestState extends EventDispatcher {
        public var p:PubNub;
        public var channel:String;
        public var messageString:String;

        [Before(async)]
        public function setUp():void {
            p = new PubNub(TestHelper.demoConfig);
            channel = TestHelper.generateChannel();
            messageString = 'Hi from ActionScript';
        }

        [Test(async, timeout=5000, description="#state() should be able to set state for uuid")]
        public function testSetState():void {
            var uuid:String = p.uuid();
            var state:Object = { 'name': 'name-' + uuid};

            var stateHandler:Function;
            var stateHandler2:Function;
            var subscribeConnectFunction:Function;
            var subscribeConnectFunction2:Function;

            stateHandler = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertObjectEquals(state, event.result);
            };

            stateHandler2 = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertObjectEquals(state, event.result);
            };

            subscribeConnectFunction = Async.asyncHandler(this, stateHandler, 4000);
            subscribeConnectFunction2 = Async.asyncHandler(this, stateHandler2, 4000);

            addEventListener(PubNubEvent.WHERE_NOW_RESULT + '_STATE', subscribeConnectFunction);
            addEventListener(PubNubEvent.WHERE_NOW_RESULT + '_STATE2', subscribeConnectFunction2);

            p.state({
                channel: channel,
                uuid: uuid,
                state: state,
                callback: function (response:Object):void {
                    dispatchEvent(new PubNubEvent(PubNubEvent.WHERE_NOW_RESULT + '_STATE', response));
                    p.state({
                        channel: channel,
                        uuid: uuid,
                        callback: function (response:Object):void {
                            dispatchEvent(new PubNubEvent(PubNubEvent.WHERE_NOW_RESULT + '_STATE2', response));
                        }
                    });
                }
            });
        }

        [Ignore]
        [Test(async, timeout=5000, description="#state() should be able to delete state for uuid")]
        public function testDeleteState():void {
            var uuid:String = p.uuid();
            var state:Object = {name: 'name-' + uuid, age: "50"};

            var stateHandler:Function;
            var stateHandler2:Function;
            var stateHandler3:Function;
            var stateHandler4:Function;
            var subscribeConnectFunction:Function;
            var subscribeConnectFunction2:Function;
            var subscribeConnectFunction3:Function;
            var subscribeConnectFunction4:Function;

            stateHandler = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertObjectEquals(state, event.result);
            };

            stateHandler2 = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertObjectEquals(state, event.result);
            };

            stateHandler3 = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertObjectEquals(state, event.result);
            };

            stateHandler4 = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertObjectEquals(state, event.result);
            };

            subscribeConnectFunction = Async.asyncHandler(this, stateHandler, 4000);
            subscribeConnectFunction2 = Async.asyncHandler(this, stateHandler2, 4000);
            subscribeConnectFunction3 = Async.asyncHandler(this, stateHandler3, 4000);
            subscribeConnectFunction4 = Async.asyncHandler(this, stateHandler4, 4000);

            addEventListener(PubNubEvent.WHERE_NOW_RESULT + '_STATE', subscribeConnectFunction);
            addEventListener(PubNubEvent.WHERE_NOW_RESULT + '_STATE2', subscribeConnectFunction2);
            addEventListener(PubNubEvent.WHERE_NOW_RESULT + '_STATE3', subscribeConnectFunction3);
            addEventListener(PubNubEvent.WHERE_NOW_RESULT + '_STATE4', subscribeConnectFunction4);

            p.state({
                channel: channel,
                uuid: uuid,
                state: state,
                callback: function (response:Object):void {
                    dispatchEvent(new PubNubEvent(PubNubEvent.WHERE_NOW_RESULT + '_STATE', response));
                    p.state({
                        channel: channel,
                        uuid: uuid,
                        callback: function (response:Object):void {
                            dispatchEvent(new PubNubEvent(PubNubEvent.WHERE_NOW_RESULT + '_STATE2', response));
                            delete state.age;
                            p.state({
                                channel: channel,
                                uuid: uuid,
                                state: {age: "null"},
                                callback: function (response:Object):void {
                                    dispatchEvent(new PubNubEvent(PubNubEvent.WHERE_NOW_RESULT + '_STATE3', response));
                                    p.state({
                                        channel: channel,
                                        uuid: uuid,
                                        callback: function (response:Object):void {
                                            dispatchEvent(new PubNubEvent(PubNubEvent.WHERE_NOW_RESULT + '_STATE4', response));
                                        }
                                    });
                                }
                            });
                        }
                    });
                }
            });
        }
    }
}
