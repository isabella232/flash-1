package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;

    import flexunit.framework.Assert;

    public class TestCipherKey extends EventDispatcher {
        public var p:PubNub;

        [Before]
        public function setUp():void {
            p = new PubNub(TestHelper.demoConfig);
        }

        [Test(description="Should be able to set and get cipher key")]
        public function testGetAndSetCipherKey():void {
            var expected:String = 'someCipherKey';
            p.set_cipher_key(expected);
            Assert.assertEquals(expected, p.get_cipher_key());
        }
    }
}
