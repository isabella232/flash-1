package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;

    import flexunit.framework.Assert;

    import org.flexunit.async.Async;

    public class TestTime extends EventDispatcher {
        public var p:PubNub;
        public var channel:String;
        public var messageString:String;

        [Before(async)]
        public function setUp():void {
            p = new PubNub(TestHelper.demoConfig);
            channel = TestHelper.generateChannel();
            messageString = 'Hi from ActionScript';
        }

        [Test(async, timeout=1000, description="Should return timestamp")]
        public function testTime():void {
            var callbackFunction:Function;

            callbackFunction = Async.asyncHandler(this, handleTimeResult, 1000);
            addEventListener(PubNubEvent.TIME_RESULT, callbackFunction);

            p.time(function (message:String):void {
                dispatchEvent(new PubNubEvent(PubNubEvent.TIME_RESULT, message));
            });
        }

        protected function handleTimeResult(event:PubNubEvent, passThroughData:Object):void {
            Assert.assertTrue(parseInt(event.result) > 0);
        }
    }
}
