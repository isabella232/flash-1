package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;

    import flexunit.framework.Assert;

    import org.flexunit.async.Async;

    public class TestUUID extends EventDispatcher {
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

        [Test(async, timeout=1000, description="Should generate uuid")]
        public function testUUID():void {
            resultFunction = Async.asyncHandler(this, handleUUIDResult, 1000);
            addEventListener(PubNubEvent.UUID_RESULT, resultFunction);

            p.uuid(function (message:String):void {
                dispatchEvent(new PubNubEvent(PubNubEvent.UUID_RESULT, message));
            });
        }

        [Test(async, timeout=1000, description="Should set uuid")]
        public function testSetUUID():void {
            var expected:String = "uglyUUID";

            resultFunction = Async.asyncHandler(this, handleSetUUIDResult, 1000, expected);
            addEventListener(PubNubEvent.SET_UUID_RESULT, resultFunction);

            p.set_uuid(expected);
            p.get_uuid(function (message:String):void {
                dispatchEvent(new PubNubEvent(PubNubEvent.SET_UUID_RESULT, message));
            });
        }

        protected function handleUUIDResult(event:PubNubEvent, passThroughData:Object):void {
            Assert.assertMatch('not matched to uuid regex', /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/, event.result);
        }

        protected function handleSetUUIDResult(event:PubNubEvent, uuid:String):void {
            Assert.assertEquals(uuid, event.result);
        }
    }
}
