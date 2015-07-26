package applicationTest {
import com.pubnub.PubNub;

import flash.events.EventDispatcher;
import flash.utils.setTimeout;

import flexunit.framework.Assert;

import org.flexunit.asserts.fail;

import org.flexunit.async.Async;

public class TestWildcardSubscribe extends EventDispatcher {
    public var pubnub:PubNub;
    public var channel:String;

    [Before(async)]
    public function setUp():void {
        pubnub = new PubNub(TestHelper.dsConfig);
    }

    [Test(async, timeout=4000, description="Should should message sent to a channel which matches wildcard")]
    public function testMessageSentToWCChannel():void {
        var random:String = TestHelper.generateChannel();
        var ch:String = 'channel-' + random;
        var chw:String = ch + '.*';
        var chwc:String = ch + ".a";

        var connectedFunction:Function;
        var resultHandler:Function;

        resultHandler = function (event:PubNubEvent, result:Object):void {
            Assert.assertObjectEquals("OK", event.result);
        };

        connectedFunction = Async.asyncHandler(this, resultHandler, 15000, null);
        addEventListener(PubNubEvent.SUBSCRIBE_RESULT, connectedFunction);

        pubnub.subscribe({
            channel: chw,
            connect: function ():void {
                pubnub.publish({
                    'channel': chwc,
                    message: 'message' + chwc,
                    callback: function (...args):void {
                    },
                    error: function (...args):void {
                        fail("error occurred in publish");
                    }
                });
            },
            callback: function (response:*, ...args):void {
                Assert.assertEquals(response, 'message' + chwc);
                pubnub.unsubscribe({channel: chw});
                dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, "OK"));
            },
            error: function (...args):void {
                fail("error occurred in subscribe");
                pubnub.unsubscribe({channel: ch});
                dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, "FAILED"));
            }
        });
    }

    [Test(async, timeout=10000, description="Should be able to subscribe on foo.* and receive presence events on foo.bar-pnpres when presence callback is provided")]
    public function testSubscribeAndReceivePresence():void {
        var count:int = 3;

        function d():void {
            if (--count == 0)
                dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, "OK"));
        }

        var random:String = TestHelper.generateChannel();
        var ch:String = 'channel-' + random;
        var chw:String = ch + '.*';
        var chwc:String = ch + ".a";

        var pubnub2:PubNub = new PubNub({
            publish_key: 'ds',
            subscribe_key: 'ds',
            origin: 'pubsub.pubnub.com',
            build_u: true
        });

        var connectedFunction:Function;
        var resultHandler:Function;

        resultHandler = function (event:PubNubEvent, result:Object):void {
            Assert.assertEquals("OK", event.result);
        };

        connectedFunction = Async.asyncHandler(this, resultHandler, 15000, null);
        addEventListener(PubNubEvent.SUBSCRIBE_RESULT, connectedFunction);

        pubnub.subscribe({
            channel: chw,
            presence: function (a:*, b:*, x:*, ...args):void {
                Assert.assertObjectEquals(x, chw);
                d();
            },
            connect: function ():void {
                setTimeout(function ():void {
                    pubnub2.subscribe({
                        channel: chwc,
                        connect: function (...args):void {
                            pubnub2.publish({
                                'channel': chwc,
                                message: 'message' + chwc,
                                callback: function (...args):void {
                                },
                                error: function (...args):void {
                                    fail('error occurred in publish');
                                }
                            });

                        },
                        callback: function (response:String, ...args):void {
                            Assert.assertEquals(response, 'message' + chwc);
                            pubnub2.unsubscribe({channel: chwc});
                            d();
                        },
                        error: function (...args):void {
                            fail("error occurred in subscribe");
                            pubnub2.unsubscribe({channel: ch});
                            dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, "FAIL"));
                        }
                    });
                }, 5000);
            },
            callback: function (response:String, ...args):void {
                Assert.assertEquals(response, 'message' + chwc);
                pubnub.unsubscribe({channel: chw});
                d();
            },
            error: function (...args):void {
                fail("error occurred in subscribe");
                pubnub.unsubscribe({channel: ch});
                dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, "FAIL"));
            }
        });
    }

    [Test(async, timeout=10000, description="Should be able to subscribe on foo.* and should not receive presence events on foo.bar-pnpres when presence callback is not provided")]
    public function testSubscribeAndNotReceivePresence():void {
        var count:int = 2;

        function d():void {
            if (--count == 0)
                dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, "OK"));
        }

        var random:String = TestHelper.generateChannel();
        var ch:String = 'channel-' + random;
        var chw:String = ch + '.*';
        var chwc:String = ch + ".a";

        var pubnub2:PubNub = new PubNub({
            publish_key: 'ds',
            subscribe_key: 'ds',
            origin: 'pubsub.pubnub.com',
            build_u: true
        });

        var connectedFunction:Function;
        var resultHandler:Function;

        resultHandler = function (event:PubNubEvent, result:Object):void {
            Assert.assertEquals("OK", event.result);
        };

        connectedFunction = Async.asyncHandler(this, resultHandler, 15000, null);
        addEventListener(PubNubEvent.SUBSCRIBE_RESULT, connectedFunction);

        pubnub.subscribe({
            channel: chw,
            connect: function ():void {
                setTimeout(function ():void {
                    pubnub2.subscribe({
                        channel: chwc,
                        connect: function ():void {
                            pubnub2.publish({
                                'channel': chwc,
                                message: 'message' + chwc,
                                callback: function (...args):void {
                                },
                                error: function (...args):void {
                                    fail('error occurred in publish');
                                }
                            });
                        },
                        callback: function (response:String, ...args):void {
                            Assert.assertEquals(response, 'message' + chwc);
                            pubnub2.unsubscribe({channel: chwc});
                            d();
                        },
                        error: function (...args):void {
                            fail("error occurred");
                            pubnub2.unsubscribe({channel: ch});
                            dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, "FAIL"));
                        }
                    });
                }, 5000);
            },
            callback: function (response:String, ...args):void {
                Assert.assertEquals(response, 'message' + chwc);
                pubnub.unsubscribe({channel: chw});
                d();
            },
            error: function (...args):void {
                fail("error occurred");
                pubnub.unsubscribe({channel: ch});
                dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, "FAIL"));
            }
        });
    }

    [Test(async, timeout=15000, description="Should be able to handle wildcard, channel group and channel together")]
    public function testSubscribeConnected():void {
        var count:int = 3;

        function d():void {
            if (--count == 0)
                dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, "OK"));
        }

        var random:String = TestHelper.generateChannel();
        var ch:String = 'channel-' + random;
        var chg:String = 'channel-group-' + random;
        var chgc:String = 'channel-group-channel' + random;
        var chw:String = ch + '.*';
        var chwc:String = ch + ".a";

        var connectedFunction:Function;
        var resultHandler:Function;

        resultHandler = function (event:PubNubEvent, result:Object):void {
            Assert.assertObjectEquals("OK", event.result);
        };

        connectedFunction = Async.asyncHandler(this, resultHandler, 15000, null);
        addEventListener(PubNubEvent.SUBSCRIBE_RESULT, connectedFunction);

        pubnub.channel_group_add_channel({
            channel_group: chg,
            channels: chgc,
            callback: function (...args):void {
                pubnub.channel_group_list_channels({
                    channel_group: chg,
                    callback: function (...args):void {
                        setTimeout(function ():void {
                            pubnub.subscribe({
                                channel: ch,
                                connect: function (...args):void {
                                    pubnub.subscribe({
                                        channel: chw,
                                        connect: function (...args):void {
                                            pubnub.subscribe({
                                                channel_group: chg,
                                                connect: function (...args):void {
                                                    setTimeout(function (...args):void {
                                                        pubnub.publish({
                                                            channel: ch,
                                                            message: 'message' + ch,
                                                            callback: function (...args):void {
                                                                pubnub.publish({
                                                                    channel: chwc,
                                                                    message: 'message' + chwc,
                                                                    callback: function (...args):void {
                                                                        pubnub.publish({
                                                                            channel: chgc,
                                                                            message: 'message' + chgc,
                                                                            callback: function (...args):void {
                                                                            },
                                                                            error: function (...args):void {
                                                                                fail('error occurred in publish');
                                                                            }
                                                                        })
                                                                    },
                                                                    error: function (...args):void {
                                                                        fail('error occurred in publish');
                                                                    }
                                                                })
                                                            },
                                                            error: function (...args):void {
                                                                fail('error occurred in publish');
                                                            }
                                                        })
                                                    }, 5000);
                                                },
                                                callback: function (response:*, ...args):void {
                                                    Assert.assertEquals(response, 'message' + chgc);
                                                    pubnub.unsubscribe({channel_group: chg});
                                                    d();
                                                },
                                                error: function (...args):void {
                                                    pubnub.unsubscribe({channel: ch});
                                                    dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, "FAIL"));
                                                }
                                            });
                                        },
                                        callback: function (response:*, ...args):void {
                                            Assert.assertEquals(response, 'message' + chwc);
                                            d();
                                        },
                                        error: function (...args):void {
                                            pubnub.unsubscribe({channel: ch});
                                            fail("");
                                        }
                                    });
                                },
                                callback: function (response:String, ...args):void {
                                    Assert.assertEquals(response, 'message' + ch);
                                    d();
                                },
                                error: function (...args):void {
                                    pubnub.unsubscribe({channel: ch});
                                    fail("");
                                }
                            })
                        }, 5000);
                    },
                    error: function (...args):void {
                        fail("error occurred in adding channel to group");
                    }
                });
            },
            error: function (...args):void {
                fail("error occurred");
            }
        });
    }

    [Test(async, timeout=15000, description="Should be able to grant read write access for wildcard channel")]
    public function testWildcardPAM():void {
        var auth_key:String = "abcd";
        var grant_channel_local:String = TestHelper.generateChannel();

        var connectedFunction:Function;
        var resultHandler:Function;

        resultHandler = function (event:PubNubEvent, result:Object):void {
            Assert.assertObjectEquals("OK", event.result);
        };

        connectedFunction = Async.asyncHandler(this, resultHandler, 15000, null);
        addEventListener(PubNubEvent.SUBSCRIBE_RESULT, connectedFunction);

        setTimeout(function ():void {
            pubnub.grant({
                channel: grant_channel_local + "*",
                'auth_key': auth_key,
                read: true,
                write: true,
                callback: function ():void {
                    pubnub.audit({
                        channel: grant_channel_local + "*",
                        'auth_key': auth_key,
                        callback: function (response:*, ...args):void {
                            Assert.assertEquals(response.auths[auth_key].r, 1);
                            Assert.assertEquals(response.auths[auth_key].w, 1);
                            pubnub.history({
                                channel: grant_channel_local + "a",
                                auth_key: auth_key,
                                callback: function (...args):void {
                                    pubnub.publish({
                                        channel: grant_channel_local + "a",
                                        auth_key: auth_key,
                                        message: 'Test',
                                        callback: function ():void {
                                            dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, "OK"));
                                        },
                                        'error': function ():void {
                                            fail("Unable to publish to granted channel");
                                        }
                                    })
                                },
                                'error': function ():void {
                                    fail("Unable to get history of granted channel");
                                }
                            });
                        }
                    });
                }
            })
        }, 5000);
    }
}
}
