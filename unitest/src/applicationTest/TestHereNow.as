package applicationTest {
    import com.pubnub.PubNub;

    import flash.events.EventDispatcher;
    import flash.utils.setTimeout;

    import flexunit.framework.Assert;

    import org.flexunit.async.Async;
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.hasItem;
    import org.hamcrest.object.hasProperty;
    import org.hamcrest.object.strictlyEqualTo;

    public class TestHereNow extends EventDispatcher {
        public var p:PubNub;
        public var p1:PubNub;
        public var p2:PubNub;
        public var p3:PubNub;
        public var uuid:String;
        public var uuid1:String;
        public var uuid2:String;
        public var uuid3:String;
        public var channel:String;

        public var ch:String;
        public var ch1:String;
        public var ch2:String;
        public var ch3:String;

        private var finalCallback:Function;
        private var finalFunction:Function;

        [Before(async)]
        public function setUp():void {
            uuid = TestHelper.demoConfig.uuid;
            uuid1 = TestHelper.demoConfig.uuid + '-1';
            uuid2 = TestHelper.demoConfig.uuid + '-2';
            uuid3 = TestHelper.demoConfig.uuid + '-3';

            var config:Object;
            config = TestHelper.demoConfig;
            p = new PubNub(config);
            config.uuid = uuid1;
            p1 = new PubNub(config);
            config.uuid = uuid2;
            p2 = new PubNub(config);
            config.uuid = uuid3;
            p3 = new PubNub(config);

            channel = TestHelper.generateChannel();
        }

        [Test(async, timeout=20000, description="Should show occupancy of channel")]
        public function testHereNow():void {
            finalCallback = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertEquals(1, event.result.occupancy);
            };

            finalFunction = Async.asyncHandler(this, finalCallback, 20000);
            addEventListener(PubNubEvent.HERE_NOW_RESULT, finalFunction);

            p.subscribe({
                channel: channel,
                message: subscribeMessageHandler,
                connect: function subscribeConnectHandler(channel:String):void {
                    setTimeout(function ():void {
                        p.here_now({
                            channel: channel,
                            callback: function (message:Object):void {
                                dispatchEvent(new PubNubEvent(PubNubEvent.HERE_NOW_RESULT, message));
                                p.unsubscribe({channel: channel});
                            }
                        });
                    }, 15000);
                    p.publish({
                        channel: channel,
                        message: 'hi'
                    })
                }
            });
        }

        [Test(async, timeout=12000, description="#here_now() should return channel channel list with occupancy details and uuids for a subscribe key")]
        public function testHereNowOccupancyAndUUIDs():void {
            ch = channel;
            ch1 = ch + '_1';
            ch2 = ch + '_2';
            ch3 = ch + '_3';

            finalCallback = function (event:PubNubEvent, passThroughData:Object):void {
                assertThat(event.result.channels, hasProperty(ch,
                        hasProperty('uuids', hasItem(uuid))
                ));

                assertThat(event.result.channels, hasProperty(ch,
                        hasProperty('occupancy', strictlyEqualTo(1))
                ));

                assertThat(event.result.channels, hasProperty(ch1,
                        hasProperty('uuids', hasItem(uuid1))
                ));

                assertThat(event.result.channels, hasProperty(ch,
                        hasProperty('occupancy', strictlyEqualTo(1))
                ));

                assertThat(event.result.channels, hasProperty(ch2,
                        hasProperty('uuids', hasItem(uuid2))
                ));

                assertThat(event.result.channels, hasProperty(ch2,
                        hasProperty('occupancy', strictlyEqualTo(1))
                ));

                assertThat(event.result.channels, hasProperty(ch3,
                        hasProperty('uuids', hasItem(uuid3))
                ));

                assertThat(event.result.channels, hasProperty(ch3,
                        hasProperty('occupancy', strictlyEqualTo(1))
                ));

                p.unsubscribe({channel: ch});
                p1.unsubscribe({channel: ch1});
                p2.unsubscribe({channel: ch2});
                p3.unsubscribe({channel: ch3});
            };

            finalFunction = Async.asyncHandler(this, finalCallback, 9000, null);
            addEventListener(PubNubEvent.HERE_NOW_RESULT, finalFunction);

            p.subscribe({
                channel: ch,
                message: subscribeMessageHandler,
                connect: function (response:Object):void {
                    p1.subscribe({
                        channel: ch1,
                        message: subscribeMessageHandler,
                        connect: function (response:Object):void {
                            p2.subscribe({
                                channel: ch2,
                                message: subscribeMessageHandler,
                                connect: function (response:Object):void {
                                    p3.subscribe({
                                        channel: ch3,
                                        message: subscribeMessageHandler,
                                        connect: function (response:Object):void {
                                            setTimeout(function ():void {
                                                p.here_now({
                                                    state: false,
                                                    callback: function (response:Object):void {
                                                        dispatchEvent(new PubNubEvent(PubNubEvent.HERE_NOW_RESULT, response));
                                                    }
                                                })
                                            }, 3000);
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }

        [Test(async, timeout=15000, description="#here_now() should return channel list with occupancy details and uuids + state for a subscribe key")]
        public function testHereNowOccupancyAndUUIDsAndState():void {
            ch = channel;
            ch1 = ch + '_1';
            ch2 = ch + '_2';
            ch3 = ch + '_3';

            p.state({
                channel: ch,
                uuid: uuid,
                state: {name: "name-" + uuid},
                callback: function (response:Object):void {
                },
                error: function (error:*):void {
                }
            });

            p1.state({
                channel: ch1,
                uuid: uuid1,
                state: {name: "name-" + uuid1},
                callback: function (response:Object):void {
                },
                error: function (error:*):void {
                }
            });

            p2.state({
                channel: ch2,
                uuid: uuid2,
                state: {name: "name-" + uuid2},
                callback: function (response:Object):void {
                },
                error: function (error:*):void {
                }
            });

            p3.state({
                channel: ch3,
                uuid: uuid3,
                state: {name: "name-" + uuid3},
                callback: function (response:Object):void {
                },
                error: function (error:*):void {
                }
            });

            finalCallback = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertTrue(event.result.channels[ch]);
                Assert.assertTrue(event.result.channels[ch1]);
                Assert.assertTrue(event.result.channels[ch2]);
                Assert.assertTrue(event.result.channels[ch3]);

                Assert.assertTrue(TestHelper.inListDeep(event.result.channels[ch].uuids, { uuid: uuid, state: { name: 'name-' + uuid }}));
                Assert.assertTrue(TestHelper.inListDeep(event.result.channels[ch1].uuids, { uuid: uuid1, state: { name: 'name-' + uuid1 }}));
                Assert.assertTrue(TestHelper.inListDeep(event.result.channels[ch2].uuids, { uuid: uuid2, state: { name: 'name-' + uuid2 }}));
                Assert.assertTrue(TestHelper.inListDeep(event.result.channels[ch3].uuids, { uuid: uuid3, state: { name: 'name-' + uuid3 }}));

                Assert.assertEquals(event.result.channels[ch].occupancy, 1);
                Assert.assertEquals(event.result.channels[ch1].occupancy, 1);
                Assert.assertEquals(event.result.channels[ch2].occupancy, 1);
                Assert.assertEquals(event.result.channels[ch3].occupancy, 1);

                p.unsubscribe({channel: ch});
                p1.unsubscribe({channel: ch1});
                p2.unsubscribe({channel: ch2});
                p3.unsubscribe({channel: ch3});
            };

            finalFunction = Async.asyncHandler(this, finalCallback, 11000);
            addEventListener(PubNubEvent.HERE_NOW_RESULT, finalFunction);

            p.subscribe({
                channel: ch,
                message: subscribeMessageHandler,
                connect: function (response:Object):void {
                    p1.subscribe({
                        channel: ch1,
                        message: subscribeMessageHandler,
                        connect: function (response:Object):void {
                            p2.subscribe({
                                channel: ch2,
                                message: subscribeMessageHandler,
                                connect: function (response:Object):void {
                                    p3.subscribe({
                                        channel: ch3,
                                        message: subscribeMessageHandler,
                                        connect: function (response:Object):void {
                                            setTimeout(function ():void {
                                                p.here_now({
                                                    state: true,
                                                    callback: function (response:Object):void {
                                                        dispatchEvent(new PubNubEvent(PubNubEvent.HERE_NOW_RESULT, response));
                                                    }
                                                })
                                            }, 3000);
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })
        }

        [Test(async, timeout=35000, description="#here_now() should return correct state for uuid in different channels")]
        public function testHereNowStateForUUIDInDifferentChannels():void {
            ch = channel;
            ch1 = ch + '_1';
            ch2 = ch + '_2';
            ch3 = ch + '_3';

            p.state({
                channel: ch,
                uuid: uuid,
                state: {name: "name-" + uuid},
                callback: function (response:Object):void {
                },
                error: function (error:*):void {
                }
            });

            p.state({
                channel: ch1,
                uuid: uuid,
                state: {name: "name-" + uuid1},
                callback: function (response:Object):void {
                },
                error: function (error:*):void {
                }
            });

            p.state({
                channel: ch2,
                uuid: uuid,
                state: {name: "name-" + uuid2},
                callback: function (response:Object):void {
                },
                error: function (error:*):void {
                }
            });

            p.state({
                channel: ch3,
                uuid: uuid,
                state: {name: "name-" + uuid3},
                callback: function (response:Object):void {
                },
                error: function (error:*):void {
                }
            });

            finalCallback = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertTrue(event.result.channels[ch]);
                Assert.assertTrue(event.result.channels[ch1]);
                Assert.assertTrue(event.result.channels[ch2]);
                Assert.assertTrue(event.result.channels[ch3]);

                Assert.assertTrue(TestHelper.inListDeep(event.result.channels[ch].uuids, { uuid: uuid, state: { name: 'name-' + uuid }}));
                Assert.assertTrue(TestHelper.inListDeep(event.result.channels[ch1].uuids, { uuid: uuid, state: { name: 'name-' + uuid1 }}));
                Assert.assertTrue(TestHelper.inListDeep(event.result.channels[ch2].uuids, { uuid: uuid, state: { name: 'name-' + uuid2 }}));
                Assert.assertTrue(TestHelper.inListDeep(event.result.channels[ch3].uuids, { uuid: uuid, state: { name: 'name-' + uuid3 }}));

                Assert.assertEquals(event.result.channels[ch].occupancy, 1);
                Assert.assertEquals(event.result.channels[ch1].occupancy, 1);
                Assert.assertEquals(event.result.channels[ch2].occupancy, 1);
                Assert.assertEquals(event.result.channels[ch3].occupancy, 1);

                p.unsubscribe({channel: ch});
                p.unsubscribe({channel: ch1});
                p.unsubscribe({channel: ch2});
                p.unsubscribe({channel: ch3});
            };

            finalFunction = Async.asyncHandler(this, finalCallback, 29000);
            addEventListener(PubNubEvent.HERE_NOW_RESULT, finalFunction);

            setTimeout(function ():void {
                p.subscribe({
                    channel: ch,
                    message: subscribeMessageHandler,
                    connect: function (response:Object):void {
                        p.subscribe({
                            channel: ch1,
                            message: subscribeMessageHandler,
                            connect: function (response:Object):void {
                                p.subscribe({
                                    channel: ch2,
                                    message: subscribeMessageHandler,
                                    connect: function (response:Object):void {
                                        p.subscribe({
                                            channel: ch3,
                                            message: subscribeMessageHandler,
                                            connect: function (response:Object):void {
                                                setTimeout(function ():void {
                                                    p.here_now({
                                                        state: true,
                                                        callback: function (response:Object):void {
                                                            dispatchEvent(new PubNubEvent(PubNubEvent.HERE_NOW_RESULT, response));
                                                        }
                                                    })
                                                }, 3000);
                                            }
                                        })
                                    }
                                })
                            }
                        })
                    }
                })
            }, 5000);
        }

        [Test(async, timeout=15000, description="#here_now() should return correct state for multiple uuids in single channel")]
        public function testHereNowStateForMultipleUUIDsInSingleChannel():void {
            ch = channel;
            ch1 = ch + '_1';
            ch2 = ch + '_2';
            ch3 = ch + '_3';

            p.state({
                channel: ch,
                uuid: uuid,
                state: {name: "name-" + uuid},
                callback: function (response:Object):void {
                },
                error: function (error:*):void {
                }
            });

            p.state({
                channel: ch,
                uuid: uuid1,
                state: {name: "name-" + uuid1},
                callback: function (response:Object):void {
                },
                error: function (error:*):void {
                }
            });

            p.state({
                channel: ch,
                uuid: uuid2,
                state: {name: "name-" + uuid2},
                callback: function (response:Object):void {
                },
                error: function (error:*):void {
                }
            });

            p.state({
                channel: ch,
                uuid: uuid3,
                state: {name: "name-" + uuid3},
                callback: function (response:Object):void {
                },
                error: function (error:*):void {
                }
            });

            finalCallback = function (event:PubNubEvent, passThroughData:Object):void {
                Assert.assertTrue(event.result.channels[ch]);

                Assert.assertTrue(TestHelper.inListDeep(event.result.channels[ch].uuids, { uuid: uuid, state: { name: 'name-' + uuid }}));
                Assert.assertTrue(TestHelper.inListDeep(event.result.channels[ch].uuids, { uuid: uuid1, state: { name: 'name-' + uuid1 }}));
                Assert.assertTrue(TestHelper.inListDeep(event.result.channels[ch].uuids, { uuid: uuid2, state: { name: 'name-' + uuid2 }}));
                Assert.assertTrue(TestHelper.inListDeep(event.result.channels[ch].uuids, { uuid: uuid3, state: { name: 'name-' + uuid3 }}));

                Assert.assertEquals(event.result.channels[ch].occupancy, 4);

                p.unsubscribe({channel: ch});
                p1.unsubscribe({channel: ch});
                p2.unsubscribe({channel: ch});
                p3.unsubscribe({channel: ch});
            };

            finalFunction = Async.asyncHandler(this, finalCallback, 11000);
            addEventListener(PubNubEvent.HERE_NOW_RESULT, finalFunction);

            setTimeout(function ():void {
                p.subscribe({
                    channel: ch,
                    message: subscribeMessageHandler,
                    connect: function (response:Object):void {
                        p1.subscribe({
                            channel: ch,
                            message: subscribeMessageHandler,
                            connect: function (response:Object):void {
                                p2.subscribe({
                                    channel: ch,
                                    message: subscribeMessageHandler,
                                    connect: function (response:Object):void {
                                        p3.subscribe({
                                            channel: ch,
                                            message: subscribeMessageHandler,
                                            connect: function (response:Object):void {
                                                setTimeout(function ():void {
                                                    p.here_now({
                                                        state: true,
                                                        callback: function (response:Object):void {
                                                            dispatchEvent(new PubNubEvent(PubNubEvent.HERE_NOW_RESULT, response));
                                                        }
                                                    })
                                                }, 3000);
                                            }
                                        })
                                    }
                                })
                            }
                        })
                    }
                })
            }, 5000);
        }

        private function subscribeMessageHandler(message:Object, envelope:Object, channel:String, time:Number):void {
        }
    }
}
