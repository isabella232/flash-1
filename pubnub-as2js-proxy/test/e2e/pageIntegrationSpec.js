"use strict";

var expect = chai.expect;

describe('Page integration', function () {
    describe('proxy object', function () {
        it('should exist on page', function () {
            expect(PUBNUB_AS2JS_PROXY).to.be.a('object');
            expect(PUBNUB_AS2JS_PROXY).to.respondTo('setFlashObjectId');
        });

        it('should respond to common delegated methods', function () {
            expect(PUBNUB_AS2JS_PROXY).to.respondTo('publish');
            expect(PUBNUB_AS2JS_PROXY).to.respondTo('subscribe');
        })
    });

    describe('flash object getter', function () {
        it("should query dom for flash object if it's local value is null", function () {
            var flashObject = document.getElementById('pubnubFlashObject');

            PUBNUB_AS2JS_PROXY.flashObject = null;

            expect(PUBNUB_AS2JS_PROXY.getFlashObject()).to.equal(flashObject);
        });
    });
});