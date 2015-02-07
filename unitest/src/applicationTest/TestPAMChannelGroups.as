package applicationTest {
import com.pubnub.PubNub;

import flash.events.EventDispatcher;
import flash.utils.setTimeout;

import flexunit.framework.Assert;

import org.flexunit.async.Async;

public class TestPAMChannelGroups extends EventDispatcher {
    public var p:PubNub;
    public var channel:String;
    public var channelGroup:String;
    public var nsp:String;
    public var authKey:String;

    [Before(async)]
    public function setUp():void {
        p = new PubNub(TestHelper.pamConfig36);
        channel = TestHelper.generateChannel();
        channelGroup = TestHelper.generateChannelGroup();
        nsp = "ftest";
        authKey = "blah";
    }

    [Test(async, timeout=7000, description="Should grant, audit and revoke to non namespaced cg for all")]
    public function testGrantAllNonNamespacedChannelGroup():void {
        var REVOKE_CALLBACK_EVENT:String = PubNubEvent.RW_GRANT_AUDIT_RESULT + '_REVOKE_EVENT';
        var GRANT_CALLBACK_EVENT:String = PubNubEvent.RW_GRANT_AUDIT_RESULT + '_GRANT_EVENT';

        var revokeCallback:Function;
        var revokeFunction:Function;

        var grantCallback:Function;
        var grantFunction:Function;

        revokeCallback = function (event:PubNubEvent, passThroughData:Object):void {
            Assert.assertEquals("channel-group", event.result.level);
            Assert.assertEquals(0, event.result['channel-groups'][channelGroup].r);
            Assert.assertEquals(0, event.result['channel-groups'][channelGroup].m);
        };

        grantCallback = function (event:PubNubEvent, passThroughData:Object):void {
            Assert.assertEquals("channel-group", event.result.level);
            Assert.assertEquals(1, event.result['channel-groups'][channelGroup].r);
            Assert.assertEquals(1, event.result['channel-groups'][channelGroup].m);
        };

        revokeFunction = Async.asyncHandler(this, revokeCallback, 7000);
        grantFunction = Async.asyncHandler(this, grantCallback, 7000);

        addEventListener(GRANT_CALLBACK_EVENT, grantFunction);
        addEventListener(REVOKE_CALLBACK_EVENT, revokeFunction);

        p.revoke({
            channel_group: channelGroup,
            callback: function (response:Object):void {
                p.audit({
                    channel_group: channelGroup,
                    callback: function (response:Object):void {
                        dispatchEvent(new PubNubEvent(REVOKE_CALLBACK_EVENT, response));
                        p.grant({
                            channel_group: channelGroup,
                            read: 1,
                            manage: 1,
                            callback: function (response:Object):void {
                                setTimeout(function ():void {
                                    p.audit({
                                        channel_group: channelGroup,
                                        callback: function (response:Object):void {
                                            dispatchEvent(new PubNubEvent(GRANT_CALLBACK_EVENT, response));
                                        }
                                    });
                                }, 5000);
                            }
                        });
                    }
                })
            }
        });
    }

    [Test(async, timeout=7000, description="Should grant, audit and revoke to non namespaced cg for specified user")]
    public function testGrantUserNonNamespacedChannelGroup():void {
        var REVOKE_CALLBACK_EVENT:String = PubNubEvent.RW_GRANT_AUDIT_RESULT + '_REVOKE_EVENT';
        var GRANT_CALLBACK_EVENT:String = PubNubEvent.RW_GRANT_AUDIT_RESULT + '_GRANT_EVENT';

        var revokeCallback:Function;
        var revokeFunction:Function;

        var grantCallback:Function;
        var grantFunction:Function;

        revokeCallback = function (event:PubNubEvent, passThroughData:Object):void {
            Assert.assertEquals(channelGroup, event.result['channel-group']);
            Assert.assertEquals("channel-group+auth", event.result.level);
            Assert.assertEquals(0, event.result.auths[authKey].r);
            Assert.assertEquals(0, event.result.auths[authKey].m);
        };

        grantCallback = function (event:PubNubEvent, passThroughData:Object):void {
            Assert.assertEquals(channelGroup, event.result['channel-group']);
            Assert.assertEquals("channel-group+auth", event.result.level);
            Assert.assertEquals(1, event.result.auths[authKey].r);
            Assert.assertEquals(1, event.result.auths[authKey].m);
        };

        revokeFunction = Async.asyncHandler(this, revokeCallback, 9000);
        grantFunction = Async.asyncHandler(this, grantCallback, 9000);

        addEventListener(GRANT_CALLBACK_EVENT, grantFunction);
        addEventListener(REVOKE_CALLBACK_EVENT, revokeFunction);

        p.revoke({
            channel_group: channelGroup,
            auth_key: authKey,
            callback: function (response:Object):void {
                p.audit({
                    channel_group: channelGroup,
                    auth_key: authKey,
                    callback: function (response:Object):void {
                        dispatchEvent(new PubNubEvent(REVOKE_CALLBACK_EVENT, response));
                        p.grant({
                            channel_group: channelGroup,
                            auth_key: authKey,
                            read: 1,
                            manage: 1,
                            callback: function (response:Object):void {
                                setTimeout(function ():void {
                                    p.audit({
                                        auth_key: authKey,
                                        channel_group: channelGroup,
                                        callback: function (response:Object):void {
                                            dispatchEvent(new PubNubEvent(GRANT_CALLBACK_EVENT, response));
                                        }
                                    });
                                }, 5000);
                            }
                        });
                    }
                })
            }
        });
    }

    [Test(async, timeout=7000, description="Should grant, audit and revoke to namespaced cg for all")]
    public function testGrantAllNamespacedChannelGroup():void {
        var REVOKE_CALLBACK_EVENT:String = PubNubEvent.RW_GRANT_AUDIT_RESULT + '_REVOKE_EVENT';
        var GRANT_CALLBACK_EVENT:String = PubNubEvent.RW_GRANT_AUDIT_RESULT + '_GRANT_EVENT';

        var namespacedGroup:String = nsp + ":" + channelGroup;

        var revokeCallback:Function;
        var revokeFunction:Function;

        var grantCallback:Function;
        var grantFunction:Function;

        revokeCallback = function (event:PubNubEvent, passThroughData:Object):void {
            Assert.assertEquals("channel-group", event.result.level);
            Assert.assertEquals(0, event.result['channel-groups'][namespacedGroup].r);
            Assert.assertEquals(0, event.result['channel-groups'][namespacedGroup].m);
        };

        grantCallback = function (event:PubNubEvent, passThroughData:Object):void {
            Assert.assertEquals("channel-group", event.result.level);
            Assert.assertEquals(1, event.result['channel-groups'][namespacedGroup].r);
            Assert.assertEquals(1, event.result['channel-groups'][namespacedGroup].m);
        };

        revokeFunction = Async.asyncHandler(this, revokeCallback, 7000);
        grantFunction = Async.asyncHandler(this, grantCallback, 7000);

        addEventListener(GRANT_CALLBACK_EVENT, grantFunction);
        addEventListener(REVOKE_CALLBACK_EVENT, revokeFunction);

        p.revoke({
            channel_group: namespacedGroup,
            callback: function (response:Object):void {
                p.audit({
                    channel_group: namespacedGroup,
                    callback: function (response:Object):void {
                        dispatchEvent(new PubNubEvent(REVOKE_CALLBACK_EVENT, response));
                        p.grant({
                            channel_group: namespacedGroup,
                            read: 1,
                            manage: 1,
                            callback: function (response:Object):void {
                                setTimeout(function ():void {
                                    p.audit({
                                        channel_group: namespacedGroup,
                                        callback: function (response:Object):void {
                                            dispatchEvent(new PubNubEvent(GRANT_CALLBACK_EVENT, response));
                                        }
                                    });
                                }, 5000);
                            }
                        });
                    }
                })
            }
        });
    }

    [Test(async, timeout=7000, description="Should grant, audit and revoke to namespaced cg for specified user")]
    public function testGrantUserNamespacedChannelGroup():void {
        var REVOKE_CALLBACK_EVENT:String = PubNubEvent.RW_GRANT_AUDIT_RESULT + '_REVOKE_EVENT';
        var GRANT_CALLBACK_EVENT:String = PubNubEvent.RW_GRANT_AUDIT_RESULT + '_GRANT_EVENT';

        var namespacedGroup:String = nsp + ":" + channelGroup;

        var revokeCallback:Function;
        var revokeFunction:Function;

        var grantCallback:Function;
        var grantFunction:Function;

        revokeCallback = function (event:PubNubEvent, passThroughData:Object):void {
            Assert.assertEquals(namespacedGroup, event.result['channel-group']);
            Assert.assertEquals("channel-group+auth", event.result.level);
            Assert.assertEquals(0, event.result.auths[authKey].r);
            Assert.assertEquals(0, event.result.auths[authKey].m);
        };

        grantCallback = function (event:PubNubEvent, passThroughData:Object):void {
            Assert.assertEquals(namespacedGroup, event.result['channel-group']);
            Assert.assertEquals("channel-group+auth", event.result.level);
            Assert.assertEquals(1, event.result.auths[authKey].r);
            Assert.assertEquals(1, event.result.auths[authKey].m);
        };

        revokeFunction = Async.asyncHandler(this, revokeCallback, 9000);
        grantFunction = Async.asyncHandler(this, grantCallback, 9000);

        addEventListener(GRANT_CALLBACK_EVENT, grantFunction);
        addEventListener(REVOKE_CALLBACK_EVENT, revokeFunction);

        p.revoke({
            channel_group: namespacedGroup,
            auth_key: authKey,
            callback: function (response:Object):void {
                p.audit({
                    channel_group: namespacedGroup,
                    auth_key: authKey,
                    callback: function (response:Object):void {
                        dispatchEvent(new PubNubEvent(REVOKE_CALLBACK_EVENT, response));
                        p.grant({
                            channel_group: namespacedGroup,
                            auth_key: authKey,
                            read: 1,
                            manage: 1,
                            callback: function (response:Object):void {
                                setTimeout(function ():void {
                                    p.audit({
                                        auth_key: authKey,
                                        channel_group: namespacedGroup,
                                        callback: function (response:Object):void {
                                            dispatchEvent(new PubNubEvent(GRANT_CALLBACK_EVENT, response));
                                        }
                                    });
                                }, 5000);
                            }
                        });
                    }
                })
            }
        });
    }
}
}
