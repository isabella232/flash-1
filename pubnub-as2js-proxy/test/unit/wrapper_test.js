"use strict";

describe('Wrapper', function () {
    beforeEach(function () {
        this.iid = 'uglyInstanceId';
        this.obj = document.createElement('object');
        this.config = {subscribe_key: 'demo', publish_key: 'demo'};
        this.payload = {some: 'useless', payload: 'here'};
        this.wrapper = new Wrapper(this.iid, this.obj, this.config);

        this.obj.callback = function () {
        };
    });

    describe('#constructor', function () {
        it('should setup instance values', function () {
            expect(this.wrapper.instanceId).to.equal(this.iid);
            expect(this.wrapper.flashObject).to.equal(this.obj);
        });

        it('should be able wrap regular PUBNUB instance', function () {
            var pubnubMock = sinon.mock(PUBNUB);

            pubnubMock.expects('init').once();
            new Wrapper(this.iid, this.obj, this.config);

            pubnubMock.verify();
        });
    });

    describe('#applyCallback', function () {
        it('should call method on flash object', function () {
            var flashMock = sinon.mock(this.wrapper.flashObject);

            flashMock.expects('callback').withExactArgs(this.iid, 'uglyCallbackId', this.payload).once();
            this.wrapper.applyCallback('uglyCallbackId', this.payload);
        });
    });

    describe('#mockCallback', function () {
        it('should return function', function () {
            var cb = this.wrapper.mockCallback('uglyCallbackId'),
                applyCallbackMock = sinon.mock(this.wrapper);

            applyCallbackMock.expects('applyCallback').withExactArgs('uglyCallbackId', [this.payload]).once();
            cb(this.payload);

            applyCallbackMock.verify();
        });
    });

    describe('#mockObjectCallbacks', function () {
        it("should wrap each object's property if it is present in fields array", function () {
            var obj = {
                    some: 'stringValue',
                    another: 'stringValue',
                    oneCallbackField: 'oneUglyCallbackId',
                    anotherCallbackField: 'anotherUglyCallbackId'
                },
                fields = ['oneCallbackField', 'anotherCallbackField'],
                applyCallbackMock = sinon.mock(this.wrapper);

            this.wrapper.mockObjectCallbacks(obj, fields);

            applyCallbackMock.expects('applyCallback').withExactArgs('oneUglyCallbackId', [this.payload]).once();
            applyCallbackMock.expects('applyCallback').withExactArgs('anotherUglyCallbackId', [this.payload]).once();

            obj.oneCallbackField(this.payload);
            obj.anotherCallbackField(this.payload);

            applyCallbackMock.verify();
        });
    });

    describe('#applyMethod', function () {
        beforeEach(function () {
            this.wrapperMock = sinon.mock(this.wrapper);
            this.cfg = {
                some: 'stringValue',
                another: 'stringValue',
                oneCallbackField: 'oneUglyCallbackId',
                anotherCallbackField: 'anotherUglyCallbackId',
                thirdCallbackField: 'thirdUglyCallbackId'
            };
            this.cb = 'uglyCallbackIdInArgs';
            this.configStub = sinon.stub(window, 'config').returns({
                callback_fields: {
                    publish: ['oneCallbackField', 'anotherCallbackField']
                },
                methods_with_callback_in_args: ['publish'],
                methods_to_delegate: ['publish']
            });
        });

        afterEach(function () {
            this.configStub.restore();
        });

        it('should mock callback ids if they are specified in config object', function () {
            var stub = sinon.stub(this.wrapper.pubnub, 'publish');
            this.wrapperMock.expects('mockCallback').withExactArgs(this.cb).once();
            this.wrapperMock.expects('mockCallback').withExactArgs('oneUglyCallbackId').once();
            this.wrapperMock.expects('mockCallback').withExactArgs('anotherUglyCallbackId').once();
            this.wrapperMock.expects('mockCallback').withExactArgs('thirdUglyCallbackId').never();

            this.wrapper.applyMethod('publish', [this.cfg, this.cb]);
            this.wrapperMock.verify();
            stub.restore();
        });

        it('should not mock last string if it is not present in config methods_with_callback_in_args array', function () {
            var stub = sinon.stub(this.wrapper.pubnub, 'subscribe');
            this.wrapperMock.expects('mockCallback').withExactArgs(this.cb).never();
            this.wrapperMock.expects('mockCallback').withExactArgs('oneUglyCallbackId').never();
            this.wrapperMock.expects('mockCallback').withExactArgs('anotherUglyCallbackId').never();

            this.wrapper.applyMethod('subscribe', [this.cfg, this.cb]);
            this.wrapperMock.verify();
            stub.restore();
        });

        it('should do nothing if called method is not specified in config.methods_to_delegate array', function () {
            var pubnubMock = sinon.mock(this.wrapper.pubnub);

            // NOTICE: subscribe now is not in methods_to_delegate array
            pubnubMock.expects('subscribe').never();
            this.wrapper.applyMethod('subscribe', [this.cfg, this.cb]);
            pubnubMock.verify();
        });

        it('should call method on pubnub instance if it is present in config.methods_to_delegate array', function () {
            var pubnubMock = sinon.mock(this.wrapper.pubnub);

            pubnubMock.expects('publish').withArgs(this.cfg).once();
            this.wrapper.applyMethod('publish', [this.cfg, this.cb]);

            pubnubMock.verify();
        });
    });

    it('#applyCallback', function () {
        var flashMock = sinon.mock(this.obj),
            stub = sinon.stub(document, 'getElementById').returns(this.obj),
            payload = [this.payload, 'someString'];

        flashMock.expects('callback').withExactArgs(this.iid, 'callbackId', payload).once();

        this.wrapper.applyCallback('callbackId', payload);

        stub.restore();
        flashMock.verify();
    });
});
