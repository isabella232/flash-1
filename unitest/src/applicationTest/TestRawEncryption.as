package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;

    import flexunit.framework.Assert;

    public class TestRawEncryption extends EventDispatcher {
        public var p:PubNub;

        [Before]
        public function setUp():void {
            p = new PubNub(TestHelper.demoConfig);
        }

        [Test(description="Should be able to encrypt and decrypt strings")]
        public function testRawEncryption():void {
            var expected:String = 'should be able to encrypt/decrypt strings';
            var key:String = 'some_key';
            var encrypted_value:String;

            encrypted_value = p.raw_encrypt(expected, key);

            Assert.assertEquals(expected, p.raw_decrypt(encrypted_value, key));
        }
    }
}
