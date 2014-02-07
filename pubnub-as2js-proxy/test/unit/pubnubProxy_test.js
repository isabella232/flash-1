"use strict";

describe("PROXY", function () {
    beforeEach(function () {
        this.p = new PubnubProxy();
    });

    describe('setFlashObjectId ', function () {
        it('should accept flash object name (string) as only argument', function () {
            var _test = this,
                failFn = function () {
                    _test.p.setFlashObjectId(15);
                },
                successFn = function () {
                    _test.p.setFlashObjectId('someId');
                };

            expectFailAndSuccessFns(failFn, successFn, TypeError);
        });
    });

    describe('initialization', function () {
        it('should have empty instances object', function () {
            expect(Object.keys(this.p.instances)).to.have.length(0);
        });

        it('should set default value for flash object', function () {
            expect(this.p.flashObjectId).to.equal('pubnubFlashObject');
        });

        it('should set default value for flash object', function () {
            expect(this.p.flashObject).to.be(null);
        });
    });

    describe('delegate methods', function () {
        it('should accept array as only argument', function () {
            var _test = this,
                failFn = function () {
                    _test.p.delegateAsync('oneMethod');
                },
                successFn = function () {
                    _test.p.delegateAsync(['oneMethod']);
                };

            expectFailAndSuccessFns(failFn, successFn, TypeError);
        });

        it('should dynamically define methods that are passed as params', function () {
            var methods = ['oneMethod', 'anotherMethod'];

            this.p.delegateAsync(methods);

            expect(this.p.oneMethod).to.be.a('function');
            expect(this.p.anotherMethod).to.be.a('function');
        });
    });

    describe('delegate synchronous methods', function () {
        it('should accept array as only argument', function () {
            var _test = this,
                failFn = function () {
                    _test.p.delegateSync('oneMethod');
                },
                successFn = function () {
                    _test.p.delegateSync(['oneMethod']);
                };

            expectFailAndSuccessFns(failFn, successFn, TypeError);
        });

        it('should dynamically define methods that are passed as params', function () {
            var methods = ['oneMethod', 'anotherMethod'];

            this.p.delegateSync(methods);

            expect(this.p.oneMethod).to.be.a('function');
            expect(this.p.anotherMethod).to.be.a('function');
        });
    });

    describe('instance creation', function () {
        beforeEach(function () {
            this.setupObject = {};
            this.i = this.p.createInstance('uglyInstanceId', this.setupObject);
        });

        it('should accept only string as instanceId', function () {
            var _test = this,
                failFn = function () {
                    _test.p.createInstance([], {});
                },
                successFn = function () {
                    _test.p.createInstance('correctInstanceId');
                };
            expectFailAndSuccessFns(failFn, successFn, TypeError);
        });

        it('should add created instance to instances object', function () {
            var ids = Object.keys(this.p.instances);

            expect(ids[0]).to.equal('uglyInstanceId');
        });
    });

    describe('instance getter', function () {
        it('should throw error when instanceId is not present in instances object', function () {
            var _test = this,
                failFn = function () {
                    _test.p.getInstance('wrongInstanceId');
                },
                successFn = function () {
                    _test.p.getInstance('uglyInstanceId');
                };

            this.p.instances = {uglyInstanceId: {}};

            expectFailAndSuccessFns(failFn, successFn, Error);
        });
    });
});