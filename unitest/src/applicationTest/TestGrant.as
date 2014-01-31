package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;
    import flash.utils.setTimeout;

    import flexunit.framework.Assert;

    import org.flexunit.async.Async;

    public class TestGrant extends EventDispatcher {
        public var p:PubNub;
        public var channel:String;
        public var messageString:String;

        [Before(async)]
        public function setUp():void {
            p = new PubNub(TestHelper.demoConfig);
            channel = TestHelper.generateChannel();
            messageString = 'Hi from ActionScript';
        }

        [Test(async, timeout=10000, description="Should be able to grant read write access")]
        public function testGrant():void {
            var a:PubNub = new PubNub(TestHelper.pamConfig);
            var auth_key:String = "asdf";

            var GRANT_CALLBACK_EVENT:String = PubNubEvent.RW_GRANT_AUDIT_RESULT + '_GRANT_EVENT';
            var AUDIT_CALLBACK_EVENT:String = PubNubEvent.RW_GRANT_AUDIT_RESULT + '_AUDIT_EVENT';

            var grantCallback:Function;
            var grantFunction:Function;

            var auditCallback:Function;
            var auditFunction:Function;

            grantCallback = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertEquals(200, event.result.status);
            };

            auditCallback = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertEquals(200, event.result.status);
            };

            grantFunction = Async.asyncHandler(this, grantCallback, 4000);
            auditFunction = Async.asyncHandler(this, auditCallback, 4000);

            addEventListener(AUDIT_CALLBACK_EVENT, auditFunction);
            addEventListener(GRANT_CALLBACK_EVENT, grantFunction);

            setTimeout(function ():void {
                a.grant({
                    channel: channel,
                    auth_key: auth_key,
                    read: true,
                    write: true,
                    ttl: 100,
                    callback: function (response:Object):void {
                        dispatchEvent(new PubNubEvent(GRANT_CALLBACK_EVENT, response));
                        a.audit({
                            channel: channel,
                            auth_key: auth_key,
                            callback: function (response:Object):void {
                                dispatchEvent(new PubNubEvent(AUDIT_CALLBACK_EVENT, response));
                            }
                        });
                    }
                });
            }, 1000);
        }
    }
}
