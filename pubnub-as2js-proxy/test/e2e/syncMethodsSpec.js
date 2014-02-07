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
});
