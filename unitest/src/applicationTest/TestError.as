package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.Event;

    import flash.events.EventDispatcher;

    import mockolate.prepare;
    import mockolate.received;

    import mockolate.runner.MockolateRule;
    import mockolate.stub;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;

    public class TestError extends EventDispatcher {
        [Rule]
        public var mocks:MockolateRule = new MockolateRule();

        [Mock(type="partial")]
        public var p:PubNub;

        [Test(async, timeout=2000, description="Should throw error from js")]
        public function testSubscribeMissingChannelError():void {
            var errorHandler:Function;
            var errorFunction:Function;

            stub(p).method('handleError').args('Missing Channel')
                .calls(function():void {
                        dispatchEvent(new PubNubEvent(PubNubEvent.ERROR, {}));
                    });

            errorHandler = function (event:PubNubEvent, passThroughData:Object):void {
                assertThat(p, received().method('handleError').args('Missing Channel'));
            };

            errorFunction = Async.asyncHandler(this, errorHandler, 4000);

            addEventListener(PubNubEvent.ERROR, errorFunction);

            p.subscribe({});
        }
    }
}
