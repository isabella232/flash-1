/**
 * Created by anovikov on 4/16/2014.
 */
package {
    import com.pubnub.air.PubNub;
    import flash.utils.setTimeout;
    import flash.utils.clearTimeout;

    public class Tests {
        private var pubnub:PubNub;
        private var asyncFunctions:Object = [];
        public function Tests() {
        }

        public function runTests(){
            if (!pubnub) {
                pubnub = new PubNub({
                    subscribe_key: 'demo',
                    publish_key: 'demo'
                });
            }

            trace('======== ====SYNCHRONOUS FUNCTIONS =========');
            assertEqual(pubnub.get_heartbeat(), 0, 'default heartbeat');
            pubnub.set_heartbeat(20);
            assertEqual(pubnub.get_heartbeat(), 20, 'heartbeat update');


            assertNotEmpty(pubnub.uuid(), 'uuid generation');
            pubnub.setUUID('blahblah');
            assertEqual(pubnub.getUUID(), 'blahblah', 'uuid setting');


            assertEqual(pubnub.get_origin(), 'pubsub', 'getting default origin');
            pubnub.set_origin('presence-beta');
            assertEqual(pubnub.get_origin(), 'presence-beta', 'updating origin');
            pubnub.set_origin('pubsub');


            assertEqual(pubnub.get_domain(), 'pubnub.com', 'getting default domain');
            pubnub.set_domain('blahblah.com');
            assertEqual(pubnub.get_domain(), 'blahblah.com', 'updating domain');
            pubnub.set_domain('pubnub.com');


            assertEqual(pubnub.get_auth_key(), null, 'auth key default value');
            pubnub.set_auth_key('blah');
            assertEqual(pubnub.get_auth_key(), 'blah', 'updating auth key');
            pubnub.unset_auth_key();
            assertEqual(pubnub.get_auth_key(), null, 'unsetting auth key');


            assertEqual(pubnub.get_non_subscribe_timeout(), 20, 'getting default nonSubscribeTimeout');
            pubnub.set_non_subscribe_timeout(15);
            assertEqual(pubnub.get_non_subscribe_timeout(), 15, 'updating nonSubscribeTimeout');
            trace('============ ASYNCHRONOUS FUNCTIONS =========');

            async('should return channel list', function (done:Function):void {
                var uuid:String = 'uglyUUID';
                pubnub.setUUID(uuid);

                pubnub.subscribe({
                    channel: 'flash_channel',
                    connect: function ():void {
                        trace('test1 subscribed', pubnub.getUUID());
                        pubnub.where_now({
                            uuid: pubnub.getUUID(),
                            callback: function (result:*):void {
                                trace(result);
                                trace('test3 done');
                                done();
                            },
                            error: function ():void {
                                trace('error:', arguments);
                            }
                        });
                    },
                    error: function ():void {
                        trace('error:', arguments);
                    },
                    callback: function ():void {
                    }
                });
            });

            async('should publish string', function (done:Function):void {
                var message:String = 'some message';
                pubnub.publish({
                    channel: 'flash_channel',
                    callback: function (result:*):void {
                        trace(result);
                        trace('test3 done');
                        done();
                    },
                    error: function ():void {
                        trace('error:', arguments);
                    }
                });
            });


            async('should subscribe to channel', function (done:Function):void {
                pubnub.subscribe({
                    channel: 'flash_channel',
                    callback: function (result:*):void {
                    },
                    connect: function (result:*):void {
                        trace('test3 done');
                        pubnub.unsubscribe('flash_channel');
                        done();
                    },
                    error: function ():void {
                        trace('error:', arguments);
                    }
                });

            });

            executeAsync();
            trace('============misc=========');
            pubnub.unsubscribe_presence('flash_channel');
            return;
            trace('End');

        }
        private function assertEqual(actual:*, expected:*, description:String = ''):void {
            if (expected === actual) {
                trace('PASS', description);
            } else {
                trace('FAIL', description, '. expected', "'" + expected + "'", 'but was', "'" + actual + "'");
            }

        }

        private function assertNotEmpty(val:*, description:String):void {
            if (val is String) {
                trace('PASS', description);
            } else {
                trace('FAIL', description);
            }
        }
        private function async(description:String, func:Function, timeout:int = 2000):void {
            asyncFunctions.push({func: func, description: description, timeout: timeout});
        }

        private function executeAsync():void {
            next();

            function execute(config:Object):void {
                var t:int = setTimeout(function ():void {
                    trace('X FAIL', config.description, 'timeout ' + config.timeout + 'ms reached');
                    next();
                }, config.timeout);

                config.func(function ():void {
                    clearTimeout(t);
                    next();
                });
            }

            function next():void {
                var next:Object = asyncFunctions.shift();
                if (next) {
                    execute(next);
                } else {
                    pubnub.shutdown();
                }
            }
        }
    }


}
