"use strict";

var expect = chai.expect,
    channel = 'as2js-proxy-test-channel-' + Date.now(),
    sandbox;

describe('Proxy object synchronous methods delegation to PUBNUB object', function () {
    before(function () {
        this.iid = 'uglyInstanceId';
        PUBNUB_AS2JS_PROXY.createInstance(this.iid, setupObject);
        this.instance = PUBNUB_AS2JS_PROXY.getInstance(this.iid);
        this.channelCounter = 0;
    });

    beforeEach(function () {
        this.setupObject = setupObject;
        this.channel = channel + ++this.channelCounter;
        sandbox = sinon.sandbox.create();
    });

    afterEach(function () {
        sandbox.restore();
    });

    describe('Synchronous methods from config', function () {
        it('should be generated after window.PUBNUB_AS2JS_PROXY instantiating', function () {
            config().sync_methods_to_delegate.forEach(function (method_name) {
                expect(PUBNUB_AS2JS_PROXY[method_name]).to.be.a('function');
            });
        })
    });

    describe('#set_uuid', function () {
        it('should set uuid without using callback', function () {
            var pubnubMock = sinon.mock(this.instance.pubnub);

            pubnubMock.expects('set_uuid').withExactArgs('someUuid').once();

            PUBNUB_AS2JS_PROXY.set_uuid(this.iid, ['someUuid']);
            pubnubMock.verify();
        });
    });
    describe('#uuid', function () {
        it('should return uuid synchronously', function () {
            expect(PUBNUB_AS2JS_PROXY.uuid(this.iid)).to.have.length.above(10);
        });
    });

    describe('#get_uuid', function () {
        it('should return uuid synchronously', function () {
            PUBNUB_AS2JS_PROXY.set_uuid(this.iid, ['someUuid']);
            expect(PUBNUB_AS2JS_PROXY.get_uuid(this.iid)).to.be.equal('someUuid');
        });
    });

    describe('#cipher_key methods', function () {
        it('should be able to set and get cipher key', function () {
            PUBNUB_AS2JS_PROXY.set_cipher_key(this.iid, ['someUnknownKey']);
            expect(PUBNUB_AS2JS_PROXY.get_cipher_key(this.iid), undefined).to.be.equal('someUnknownKey');
        });
    });

    describe('#raw_encrypt and #raw_decrypt methods', function () {
        it('should be able to encrypt/decrypt strings', function () {
            var raw_string = 'should be able to encrypt/decrypt strings';
            var key = 'kkeeyy';
            var encrypted_value = PUBNUB_AS2JS_PROXY.raw_encrypt(this.iid, [raw_string, key]);

            expect(PUBNUB_AS2JS_PROXY.raw_decrypt(this.iid, [encrypted_value, key])).to.be.equal(raw_string);
        });
    });

    describe('#set_heartbeat and #get_heartbeat methods', function () {
        it('should be able to set/get heartbeat interval', function () {
            var interval = 10;

            PUBNUB_AS2JS_PROXY.set_heartbeat(this.iid, [interval]);
            expect(PUBNUB_AS2JS_PROXY.get_heartbeat(this.iid)).to.be.equal(interval);
        });
    });
});
