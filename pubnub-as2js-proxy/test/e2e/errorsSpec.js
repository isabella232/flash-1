"use strict";

var expect = chai.expect,
    sandbox;

describe('Error', function () {
    before(function () {
        this.iid = 'uglyInstanceId';
        PUBNUB_AS2JS_PROXY.createInstance(this.iid, setupObject);
    });

    beforeEach(function () {
        this.flashObject = document.getElementById('pubnubFlashObject');
        sandbox = sinon.sandbox.create();
    });

    afterEach(function () {
        sandbox.restore();
    });

    it('should be sent if trying to make a call on unknown instance id', function (done) {
        sandbox.stub(this.flashObject, 'error', function (message) {
            expect(message).to.equal('instance with id unknownInstanceId is not present');
            done()
        });

        PUBNUB_AS2JS_PROXY.publish('unknownInstanceId', [{
            channel: 'channel',
            message: message_string
        }]);
    });

    it('should be sent if trying to create an instance with existing id', function (done) {
        var instanceId = 'theSameId';

        sandbox.stub(this.flashObject, 'error', function (message) {
            expect(message).to.equal('instance with id theSameId already exists');
            done()
        });

        PUBNUB_AS2JS_PROXY.createInstance(instanceId, setupObject);
        PUBNUB_AS2JS_PROXY.createInstance(instanceId, setupObject);
    });

    // TODO: impossible to proxy errors like 'Missing Channel' now
    it.skip("should be sent if some js error thrown during execution of one of PUBNUB's methods", function (done) {
        var _test = this;

        sandbox.stub(this.flashObject, 'instanceError', function (instanceId, message) {
            expect(instanceId).to.equal(_test.iid);
            expect(message).to.equal('Missing Channel');
            done()
        });

        PUBNUB_AS2JS_PROXY.publish(this.iid, [{
            message: message_string
        }]);
    });
});