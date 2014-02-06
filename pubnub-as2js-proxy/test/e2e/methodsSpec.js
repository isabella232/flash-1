"use strict";

var expect = chai.expect,
    channel = 'as2js-proxy-test-channel-' + Date.now(),
    sandbox;

describe('Proxy object methods delegation to PUBNUB object', function () {
    before(function () {
        this.iid = 'uglyInstanceId';
        this.siid = 'secureInstanceId';
        this.piid = 'presenceInstanceId';
        PUBNUB_AS2JS_PROXY.createInstance(this.iid, setupObject);
        PUBNUB_AS2JS_PROXY.createInstance(this.siid, secureSetupObject);
        PUBNUB_AS2JS_PROXY.createInstance(this.piid, presenceSetupObject);
        this.instance = PUBNUB_AS2JS_PROXY.getInstance(this.iid);
        this.channelCounter = 0;
    });

    beforeEach(function () {
        this.setupObject = setupObject;
        this.secureSetupObject = secureSetupObject;
        this.flashObject = document.getElementById('pubnubFlashObject');
        this.channel = channel + ++this.channelCounter;
        this.payload = {some: 'useless', payload: 'here'};
        sandbox = sinon.sandbox.create();
    });

    afterEach(function () {
        sandbox.restore();
    });

    describe('#constructor', function () {
        it('should create regular instance if only setup object is passed into constructor', function () {
            var pubnubMock = sandbox.mock(PUBNUB);

            pubnubMock.expects('init').withExactArgs(this.setupObject).once();
            PUBNUB_AS2JS_PROXY.createInstance('uglyRegularId', this.setupObject);
            pubnubMock.verify();
        });

        it('should create secure instance if setup object and true secure flag are passed into constructor', function () {
            var pubnubMock = sandbox.mock(PUBNUB);

            pubnubMock.expects('secure').withExactArgs(this.setupObject).once();
            PUBNUB_AS2JS_PROXY.createInstance('uglySecureId', this.setupObject, true);
            pubnubMock.verify();
        });

        it('should invoke callback after creating new instance', function (done) {
            var pubnubStub = sandbox.stub(PUBNUB, 'init'),
                iid = 'uglyIdForCallbackTest';

            sandbox.stub(this.flashObject, 'created', function (instanceId) {
                expect(instanceId).to.equal(iid);
                done();
            });

            PUBNUB_AS2JS_PROXY.createInstance(iid, this.setupObject);
        });
    });

    // expect that PUBNUB instance is already created
    describe('#publish', function () {
        it('should invoke callback on flash object after publishing message', function (done) {
            var _test = this;

            sandbox.stub(this.flashObject, 'callback', function (instanceId, callbackId, response) {
                response = decode64(response);
                expect(instanceId).to.equal(_test.iid);
                expect(callbackId).to.equal('uglyCallbackId');
                expect(response[0][0]).to.equal(1);
                done()
            });

            this.timeout(4000);

            PUBNUB_AS2JS_PROXY.publish(this.iid, [{
                channel: this.channel,
                message: navigator.appName,
                callback: 'uglyCallbackId'
            }]);
        });

        it('should publish multiple messages on multiple channels without failure', function (done) {
            this.timeout(10000);

            var channelsToTest = 10,
                responseCounter = 0,
                channelPrefix = hashCode.call(this.channel + navigator.userAgent + '_publish_').toString(),
                messagePrefix = 'message for channel #',
                subscribeConnectPatter = /^subscribeConnectCallbackId_(\d+)$/ ,
                subscribeMessagePatter = /^subscribeMessageCallbackId_(\d+)$/ ,
                publishedMessages = [],
                _test = this;

            sandbox.stub(this.flashObject, 'callback', function (instanceId, callbackId, response) {
                var connect = subscribeConnectPatter.exec(callbackId),
                    message = subscribeMessagePatter.exec(callbackId);

                response = decode64(response);

                if (connect) {
                    (function () {
                        var id = connect[1],
                            message = messagePrefix + id,
                            channel = channelPrefix + id;

                        PUBNUB_AS2JS_PROXY.publish(_test.iid, [{
                            message: message,
                            channel: channel
                        }]);
                    })();
                } else if (message) {
                    (function () {
                        var idFromMessage = response[0].replace(messagePrefix, ''),
                            idFromCallback = message[1];

                        if (idFromMessage === idFromCallback) {
                            if (++responseCounter === channelsToTest) {
                                done();
                            }
                        }
                    })();
                }
            });

            for (var i = 0; i < channelsToTest; i++) {
                publishedMessages.push(subscribeChannel(i));
            }

            function subscribeChannel(channel_id) {
                var channel = channelPrefix + channel_id,
                    connect = 'subscribeConnectCallbackId_' + channel_id,
                    message = 'subscribeMessageCallbackId_' + channel_id;

                PUBNUB_AS2JS_PROXY.subscribe(_test.iid, [{
                    channel: channel,
                    connect: connect,
                    message: message
                }]);
            }
        });
    });

    describe('#subscribe', function () {
        it('should invoke callback on flash object when receiving new message from server', function (done) {
            var _test = this;

            this.timeout(8000);

            sandbox.stub(this.flashObject, 'callback', function (instanceId, callbackId, response) {
                response = decode64(response);

                if (callbackId === 'connectedCallbackId') {
                    PUBNUB_AS2JS_PROXY.publish(_test.iid, [{
                        channel: _test.channel,
                        message: message_string
                    }]);
                } else if (callbackId === 'messageCallbackId') {
                    expect(response[0]).to.equal(message_string);
                    PUBNUB_AS2JS_PROXY.unsubscribe(_test.iid, [{channel: _test.channel}]);
                    done();
                }
            });

            PUBNUB_AS2JS_PROXY.subscribe(this.iid, [{
                channel: this.channel,
                message: 'messageCallbackId',
                connect: 'connectedCallbackId'
            }]);
        });
    });

    describe('#set_uuid', function () {
        it('should set uuid without using callback', function (){
            var pubnubMock = sinon.mock(this.instance.pubnub);

            pubnubMock.expects('set_uuid').withExactArgs('someUuid').once();

            PUBNUB_AS2JS_PROXY.set_uuid(this.iid, ['someUuid']);
            pubnubMock.verify();
        });
    });

    describe('#time', function () {
        it('should return current time in callback', function (done) {
            var _test = this;

            sandbox.stub(this.flashObject, 'callback', function (instanceId, callbackId, response) {
                response = decode64(response);
                expect(instanceId).to.equal(_test.iid);
                expect(callbackId).to.equal('timeCallbackId');
                expect(response[0]).to.be.at.least(13880976763149278);
                done();
            });

            PUBNUB_AS2JS_PROXY.time(this.iid, ['timeCallbackId']);
        });
    });

    describe('#uuid', function () {
        it('should return uuid in callback', function (done) {
            var _test = this;

            sandbox.stub(this.flashObject, 'callback', function (instanceId, callbackId, response) {
                response = decode64(response);
                expect(instanceId).to.equal(_test.iid);
                expect(callbackId).to.equal('uuidCallbackId');
                expect(response[0]).to.not.be.empty;
                done();
            });

            PUBNUB_AS2JS_PROXY.uuid(this.iid, 'uuidCallbackId');
        });
    });

    describe('#here_now', function () {
        it('should show occupancy 1 user if 1 user is subscribed to channel', function (done) {
            this.timeout(18000);

            var _test = this;

            sandbox.stub(this.flashObject, 'callback', function (instanceId, callbackId, response) {
                response = decode64(response);

                switch(callbackId) {
                    case 'connectedCallbackId':
                        PUBNUB_AS2JS_PROXY.publish(_test.iid, [{
                            channel: _test.channel,
                            message: message_jsona,
                            callback: 'publishCallbackId'
                        }]);
                        break;
                    case 'publishCallbackId':
                        setTimeout(function () {
                            PUBNUB_AS2JS_PROXY.here_now(_test.iid, [{
                                channel: _test.channel,
                                callback: 'hereNowCallbackId'
                            }]);
                        }, 15000);
                        break;
                    case 'hereNowCallbackId':
                        PUBNUB_AS2JS_PROXY.unsubscribe(_test.iid, [{
                            channel: _test.channel
                        }]);
                        expect(response[0].uuids).to.be.not.empty;
                        expect(response[0].occupancy).to.be.at.least(1);
                        done();
                        break;
                    default:
                        break;
                }
            });

            PUBNUB_AS2JS_PROXY.subscribe(this.iid, [{
                channel: _test.channel,
                message: 'messageCallbackId',
                connect: 'connectedCallbackId'
            }]);
        });
    });

    describe('#history', function () {
        it('#should return 2 messages when 3 were published on channel and count is 2', function (done) {
            this.timeout(8000);

            var counter = 0,
                responseCounter = 0,
                channel = this.channel + 'history',
                publishPatter = /^publishCallbackId_\d/ ,
                publishedMessages = [],
                _test = this;

            sandbox.stub(this.flashObject, 'callback', function (instanceId, callbackId, response) {
                response = decode64(response);

                if (publishPatter.test(callbackId)) {
                    if (++responseCounter === 3) {
                        setTimeout(function () {
                            PUBNUB_AS2JS_PROXY.history(_test.iid, [{
                                count: 2,
                                channel: channel,
                                callback: 'historyCallbackId'
                            }]);
                        }, 1000);
                    }
                } else if (callbackId === 'historyCallbackId') {
                    expect(instanceId).to.be.equal(_test.iid);
                    expect(response[0][0]).to.have.length(2);
                    PUBNUB_AS2JS_PROXY.unsubscribe(_test.iid, [{channel: channel}]);
                    done()
                }
            });

            for (var i = 0; i < 3; i++) {
                publishedMessages.push(publishMessage());
            }

            function publishMessage() {
                var message = message_string + ++counter;

                PUBNUB_AS2JS_PROXY.publish(_test.iid, [{
                    channel: channel,
                    message: message,
                    callback: 'publishCallbackId_' + counter
                }]);

                return message;
            }
        });
    });

    describe('#grant', function () {
        // IE 11 fails here because of using uninitialized variable data in pubnub.js v.3.5.48 row 942
        it('should invoke callback on flash object after granting permissions', function (done) {
            var _test = this;

            sandbox.stub(this.flashObject, 'callback', function (instanceId, callbackId, response) {
                response = decode64(response);
                expect(instanceId).to.equal(_test.siid);
                expect(callbackId).to.equal('uglyCallbackId');
                expect(response[0]).to.have.property('channels')
                    .that.is.an('object');
                done()
            });

            this.timeout(4000);

            PUBNUB_AS2JS_PROXY.grant(this.siid, [{
                channel: this.channel,
                read: true,
                write: true,
                ttl: 360000
            }, 'uglyCallbackId']);
        });
    });

    describe('#where_now', function () {
        it('should return channel a,b,c in result for uuid y, when uuid y subscribed to channel x', function (done) {
            var _test = this,
                emitter = new EventEmitter();

            sandbox.stub(this.flashObject, 'callback', function (instanceId, callbackId, response) {
                response = decode64(response);
                emitter.emit(callbackId, response[0]);
            });

            this.timeout(10000);

            var ch1 = channel + '-' + 'where-now' + '-1';
            var ch2 = channel + '-' + 'where-now' + '-2';
            var ch3 = channel + '-' + 'where-now' + '-3';
            var where_now_set = false;

            PUBNUB_AS2JS_PROXY.subscribe(this.piid, [
                {
                    channel: [ch1, ch2, ch3],
                    connect: 'connectCallbackId',
                    callback: 'messageCallbackId',
                    error: 'subscribeErrorCallbackId'
                }
            ]);

            emitter.on('connectCallbackId', function (channel) {
                if (!where_now_set) {
                    setTimeout(function () {
                        PUBNUB_AS2JS_PROXY.where_now(_test.piid, [
                            {
                                uuid: presence_uuid,
                                callback: 'whereNowCallbackId',
                                error: 'whereNowErrorCallbackId'
                            }
                        ]);
                    }, 7000);
                    where_now_set = true;
                }
            });

            emitter.on('whereNowCallbackId', function (data) {
                expect(data).to.have.property('channels')
                    .that.is.an('array')
                    .that.have.length(3)
                    .that.have.members([ch1, ch2, ch3]);

                PUBNUB_AS2JS_PROXY.unsubscribe(_test.piid, [
                    {channel: ch1}
                ]);
                PUBNUB_AS2JS_PROXY.unsubscribe(_test.piid, [
                    {channel: ch2}
                ]);
                PUBNUB_AS2JS_PROXY.unsubscribe(_test.piid, [
                    {channel: ch3}
                ]);
                done();
            });

            emitter.on('subscribeErrorCallbackId', function () {
                done(new Error('Error occurred in subscribe'));
            });

            emitter.on('whereNowErrorCallbackId', function (error) {
                done(new Error("Error occurred in where now " + JSON.stringify(error)));
            });
        })
    });
});
