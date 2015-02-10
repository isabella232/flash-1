package applicationTest {
import com.pubnub.PubNub;

import flash.events.EventDispatcher;
import flash.utils.setTimeout;

import flexunit.framework.Assert;

import org.flexunit.async.Async;

public class TestChannelGroups extends EventDispatcher {
    public var p:PubNub;
    public var channel:String;
    public var channelGroup:String;
    public var nsp:String;
    public var messageString:String;
    public var channels:Array;

    [BeforeClass]
    public static function cleanup():void {
        TestHelper.cleanup();
    }

    [Before(async)]
    public function setUp():void {
        p = new PubNub(TestHelper.pamConfig36);
        channel = TestHelper.generateChannel();
        channelGroup = TestHelper.generateChannelGroup();
        nsp = "ftest";
        messageString = 'Hi from ActionScript';
        channels = [channel + "-1", channel + "-2", channel + "-3"];
    }

    [Test(async, timeout=4000, description="Should respond with 200 OK")]
    public function testAddChannelToNonNameSpacedGroup():void {
        var resultFunction:Function;
        var resultHandler:Function;

        resultHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertObjectEquals("OK", event.result.message);
        };

        resultFunction = Async.asyncHandler(this, resultHandler, 4000, channel);
        addEventListener(PubNubEvent.CG_ADD, resultFunction);

        p.channel_group_add_channel({
            channel_group: channelGroup,
            channel: channel,
            callback: function channelGroupAddHandler(message:Object):void {
                dispatchEvent(new PubNubEvent(PubNubEvent.CG_ADD, message));
            }
        });
    }

    [Test(async, timeout=4000, description="Should respond with 200 OK")]
    public function testAddChannelToNameSpacedGroup():void {
        var resultFunction:Function;
        var resultHandler:Function;

        resultHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertObjectEquals("OK", event.result.message);
        };

        resultFunction = Async.asyncHandler(this, resultHandler, 4000, channel);
        addEventListener(PubNubEvent.CG_ADD, resultFunction);

        p.channel_group_add_channel({
            channel_group: nsp + channelGroup,
            channel: channel,
            callback: function channelGroupAddHandler(message:Object):void {
                dispatchEvent(new PubNubEvent(PubNubEvent.CG_ADD, message));
            }
        });
    }

    [Test(async, timeout=4000, description="Should perform add/get/remove operations on non namespaced group")]
    public function testGetChannelsOnNonNameSpacedGroup():void {
        var addFunction:Function;
        var getFunction:Function;
        var removeFunction:Function;
        var get2Function:Function;
        var addHandler:Function;
        var getHandler:Function;
        var removeHandler:Function;
        var get2Handler:Function;

        addHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertObjectEquals("OK", event.result.message);
        };

        getHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertObjectEquals(channels, event.result.channels);
            Assert.assertEquals(channelGroup, event.result.group);
        };

        removeHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertObjectEquals("OK", event.result.message);
        };

        get2Handler = function (event:PubNubEvent, message:Object):void {
            var expected:Array = [channels[0], channels[2]];

            Assert.assertObjectEquals(expected, event.result.channels);
            Assert.assertEquals(channelGroup, event.result.group);
        };

        addFunction = Async.asyncHandler(this, addHandler, 4000, channel);
        getFunction = Async.asyncHandler(this, getHandler, 4000, channel);
        removeFunction = Async.asyncHandler(this, removeHandler, 4000, channel);
        get2Function = Async.asyncHandler(this, get2Handler, 4000, channel);

        addEventListener(PubNubEvent.CG_ADD, addFunction);
        addEventListener(PubNubEvent.CG_GET_CHANNELS + "1", getFunction);
        addEventListener(PubNubEvent.CG_REMOVE_CHANNEL, removeFunction);
        addEventListener(PubNubEvent.CG_GET_CHANNELS + "2", get2Function);

        p.channel_group_add_channel({
            channel_group: channelGroup,
            channel: channels,
            callback: function channelGroupAddHandler(message:Object):void {
                dispatchEvent(new PubNubEvent(PubNubEvent.CG_ADD, message));
                p.channel_group_list_channels({
                    channel_group: channelGroup,
                    callback: function (message:Object):void {
                        dispatchEvent(new PubNubEvent(PubNubEvent.CG_GET_CHANNELS + "1", message));
                        p.channel_group_remove_channel({
                            channel_group: channelGroup,
                            channel: channels[1],
                            callback: function (message:Object):void {
                                dispatchEvent(new PubNubEvent(PubNubEvent.CG_REMOVE_CHANNEL, message));
                                setTimeout(function ():void {
                                    p.channel_group_list_channels({
                                        channel_group: channelGroup,
                                        callback: function (message:Object):void {
                                            dispatchEvent(new PubNubEvent(PubNubEvent.CG_GET_CHANNELS + "2", message));
                                        }
                                    });
                                }, 1000);
                            }
                        });
                    }
                });
            }
        });
    }

    [Test(async, timeout=4000, description="Should perform add/get/remove operations on namespaced group")]
    public function testGetChannelsOnNameSpacedGroup():void {
        var addFunction:Function;
        var getFunction:Function;
        var removeFunction:Function;
        var get2Function:Function;
        var addHandler:Function;
        var getHandler:Function;
        var removeHandler:Function;
        var get2Handler:Function;

        var namespacedGroup:String = nsp + ":" + channelGroup;

        addHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertObjectEquals("OK", event.result.message);
        };

        getHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertObjectEquals(channels, event.result.channels);
            Assert.assertEquals(channelGroup, event.result.group);
        };

        removeHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertObjectEquals("OK", event.result.message);
        };

        get2Handler = function (event:PubNubEvent, message:Object):void {
            var expected:Array = [channels[0], channels[2]];

            Assert.assertObjectEquals(expected, event.result.channels);
            Assert.assertEquals(channelGroup, event.result.group);
        };

        addFunction = Async.asyncHandler(this, addHandler, 4000, channel);
        getFunction = Async.asyncHandler(this, getHandler, 4000, channel);
        removeFunction = Async.asyncHandler(this, removeHandler, 4000, channel);
        get2Function = Async.asyncHandler(this, get2Handler, 4000, channel);

        addEventListener(PubNubEvent.CG_ADD, addFunction);
        addEventListener(PubNubEvent.CG_GET_CHANNELS + "1", getFunction);
        addEventListener(PubNubEvent.CG_REMOVE_CHANNEL, removeFunction);
        addEventListener(PubNubEvent.CG_GET_CHANNELS + "2", get2Function);

        p.channel_group_add_channel({
            channel_group: namespacedGroup,
            channel: channels,
            callback: function channelGroupAddHandler(message:Object):void {
                dispatchEvent(new PubNubEvent(PubNubEvent.CG_ADD, message));
                p.channel_group_list_channels({
                    channel_group: namespacedGroup,
                    callback: function (message:Object):void {
                        dispatchEvent(new PubNubEvent(PubNubEvent.CG_GET_CHANNELS + "1", message));
                        p.channel_group_remove_channel({
                            channel_group: namespacedGroup,
                            channel: channels[1],
                            callback: function (message:Object):void {
                                dispatchEvent(new PubNubEvent(PubNubEvent.CG_REMOVE_CHANNEL, message));
                                setTimeout(function ():void {
                                    p.channel_group_list_channels({
                                        channel_group: namespacedGroup,
                                        callback: function (message:Object):void {
                                            dispatchEvent(new PubNubEvent(PubNubEvent.CG_GET_CHANNELS + "2", message));
                                        }
                                    });
                                }, 1000);
                            }
                        });
                    }
                });
            }
        });
    }

    [Test(async, timeout=4000, description="Should perform get/remove actions on existing groups in global namespace")]
    public function testHandleAllChannelGroupNames():void {
        var firstListFunction:Function;
        var removeGroupFunction:Function;
        var secondListFunction:Function;
        var firstListHandler:Function;
        var removeGroupHandler:Function;
        var secondListHandler:Function;

        var group1:String = channelGroup + "1";
        var group2:String = channelGroup + "2";

        firstListHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertTrue(event.result.groups.indexOf(group1) >= 0);
            Assert.assertTrue(event.result.groups.indexOf(group2) >= 0);
        };

        removeGroupHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertEquals("OK", event.result.message);
        };

        secondListHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertTrue(event.result.groups.indexOf(group1) == -1);
            Assert.assertTrue(event.result.groups.indexOf(group2) >= 0);
        };

        firstListFunction = Async.asyncHandler(this, firstListHandler, 4000, channel);
        removeGroupFunction = Async.asyncHandler(this, removeGroupHandler, 4000, channel);
        secondListFunction = Async.asyncHandler(this, secondListHandler, 4000, channel);

        addEventListener(PubNubEvent.CG_GET_GROUPS + "1", firstListFunction);
        addEventListener(PubNubEvent.CG_REMOVE_GROUP, removeGroupFunction);
        addEventListener(PubNubEvent.CG_GET_GROUPS + "2", secondListFunction);

        p.channel_group_add_channel({
            channel_group: group1,
            channel: channel,
            callback: function channelGroupAddHandler(message:Object):void {
                p.channel_group_add_channel({
                    channel_group: group2,
                    channel: channel,
                    callback: function channelGroupAddHandler(message:Object):void {
                        setTimeout(function ():void {
                            p.channel_group_list_groups({
                                callback: function (message:Object):void {
                                    dispatchEvent(new PubNubEvent(PubNubEvent.CG_GET_GROUPS + "1", message));
                                    p.channel_group_remove_group({
                                        channel_group: group1,
                                        callback: function (message:Object):void {
                                            dispatchEvent(new PubNubEvent(PubNubEvent.CG_REMOVE_GROUP, message));
                                            setTimeout(function ():void {
                                                p.channel_group_list_groups({
                                                    callback: function (message:Object):void {
                                                        dispatchEvent(new PubNubEvent(PubNubEvent.CG_GET_GROUPS + "2", message));
                                                    }
                                                });
                                            }, 1000);
                                        }
                                    });
                                }
                            })
                        }, 1000);
                    }
                });
            }
        });
    }

    [Test(async, timeout=4000, description="Should perform get/remove actions on existing groups in specified namespace")]
    public function testHandleAllChannelGroupNamesNamespaced():void {
        var firstListFunction:Function;
        var removeGroupFunction:Function;
        var secondListFunction:Function;
        var firstListHandler:Function;
        var removeGroupHandler:Function;
        var secondListHandler:Function;

        var group1:String = channelGroup + "1";
        var group2:String = channelGroup + "2";

        var namespacedGroup1:String = nsp + ":" + group1;
        var namespacedGroup2:String = nsp + ":" + group2;

        firstListHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertTrue(event.result.groups.indexOf(group1) >= 0);
            Assert.assertTrue(event.result.groups.indexOf(group2) >= 0);
        };

        removeGroupHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertEquals("OK", event.result.message);
        };

        secondListHandler = function (event:PubNubEvent, message:Object):void {
            Assert.assertTrue(event.result.groups.indexOf(group1) == -1);
            Assert.assertTrue(event.result.groups.indexOf(group2) >= 0);
        };

        firstListFunction = Async.asyncHandler(this, firstListHandler, 4000, channel);
        removeGroupFunction = Async.asyncHandler(this, removeGroupHandler, 4000, channel);
        secondListFunction = Async.asyncHandler(this, secondListHandler, 4000, channel);

        addEventListener(PubNubEvent.CG_GET_GROUPS + "1", firstListFunction);
        addEventListener(PubNubEvent.CG_REMOVE_GROUP, removeGroupFunction);
        addEventListener(PubNubEvent.CG_GET_GROUPS + "2", secondListFunction);

        p.channel_group_add_channel({
            channel_group: namespacedGroup1,
            channel: channel,
            callback: function channelGroupAddHandler(message:Object):void {
                p.channel_group_add_channel({
                    channel_group: namespacedGroup2,
                    channel: channel,
                    callback: function channelGroupAddHandler(message:Object):void {
                        setTimeout(function ():void {
                            p.channel_group_list_groups({
                                namespace: nsp,
                                callback: function (message:Object):void {
                                    dispatchEvent(new PubNubEvent(PubNubEvent.CG_GET_GROUPS + "1", message));
                                    p.channel_group_remove_group({
                                        channel_group: namespacedGroup1,
                                        callback: function (message:Object):void {
                                            dispatchEvent(new PubNubEvent(PubNubEvent.CG_REMOVE_GROUP, message));
                                            setTimeout(function ():void {
                                                p.channel_group_list_groups({
                                                    namespace: nsp,
                                                    callback: function (message:Object):void {
                                                        dispatchEvent(new PubNubEvent(PubNubEvent.CG_GET_GROUPS + "2", message));
                                                    }
                                                });
                                            }, 1000);
                                        }
                                    });
                                }
                            })
                        }, 1000);
                    }
                });
            }
        });
    }
}
}
