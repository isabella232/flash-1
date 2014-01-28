package applicationTest
{
	import com.pubnub.PubNub;
	import com.pubnub.PubNubSecure;
	
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;

	public class TestApplication extends EventDispatcher
	{
		private var channel:String;
		private var	pamTtl :String;
		private var	pamChannel:String;
		private var	publish_key:String;
		private var	auth_key:String;
		private var	cipher_key:String;
		private var	subscribe_key:String;
		private var	secret_key:String;
		private var	origin:String;
		private var	isSsl:Boolean;
		public var p:PubNub;
		
		public function TestApplication()
		{
		}
		public function initConfig():void
		{
			channel  = "flash_channel";
			pamTtl = "15";
			pamChannel = "flash_channel";
			publish_key = "demo";
			auth_key = "x";
			cipher_key ="";
			subscribe_key  = "demo";
			secret_key = "demo";
			origin = "pubsub.pubnub.com";
			isSsl = false;
			
			var config:Object = {
				origin:		origin,
				publish_key: publish_key,
				sub_key:	subscribe_key,
				auth_key: auth_key,
				secret_key:	secret_key,
				cipher_key: cipher_key,
				ssl:	isSsl};
			
		}
		public function subscribe():void {
			p = (cipher_key ? PubNubSecure.init : PubNub.init)(
			
			{	auth_key:	"x"	,
				cipher_key:	""	,
				origin:	"pubsub.pubnub.com",	
				publish_key:	"demo",	
				secret_key:	"demo",	
				ssl:	false	,
				subscribe_key:	"demo"
			}
			);
			
			p.subscribe({
				backfill: false,
				noheresync: true,
				channel: channel,
				message: function subscribeMessageHandler(message:Object, envelope:Object, channel:String, time:Number):void {
					dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, message));
				},
				presence: function subscribePresenceHandler(message:Object, here:*, channel:String, presenceChannel:String = null):void {
					message.result="presence";
					dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, message));
				},
				connect: function subscribeConnectHandler(channel:String):void {
					dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, {message:channel,result:"connect"}));
					p.unsubscribe({channel:channel});
				},
				disconnect: function (message:Object):void {
					message.result="presence";
					dispatchEvent(new PubNubEvent(PubNubEvent.SUBSCRIBE_RESULT, message));},
				error: function subscribeErrorHandler(e:Object):void {
					e.result="error";
				}
			});
		}
		
		public function unsubscribe():void {
			p.unsubscribe({
				channel: channel,
				callback: function (message:Object):void {	}
			});
		}
		
		public function publish(str:*):void {
			p = (cipher_key ? PubNubSecure.init : PubNub.init)(
				{	auth_key:	"x"	,
					cipher_key:	""	,
					origin:	"pubsub.pubnub.com",	
					publish_key:	"demo",	
					secret_key:	"demo",	
					ssl:	false	,
					subscribe_key:	"demo"
				}
			);
			
			
			p.subscribe({
				backfill: false,
				noheresync: true,
				channel: channel,
				message: function subscribeMessageHandler(message:Object, envelope:Object, channel:String, time:Number):void {
					dispatchEvent(new PubNubEvent(PubNubEvent.PUBLISH_RESULT, message));
				},
				presence: function subscribePresenceHandler(message:Object, here:*, channel:String, presenceChannel:String = null):void {
					message.result="presence";
					dispatchEvent(new PubNubEvent(PubNubEvent.PUBLISH_RESULT, message));
				},
				connect: function subscribeConnectHandler(channel:String):void {
					p.publish({
						channel: channel,
						message: { "data": str },
						auth_key: auth_key,
						error: function(message:Object):void{
							message.result = "publish error";
							dispatchEvent(new PubNubEvent(PubNubEvent.PUBLISH_RESULT, message));
						}
					}, function(message:Object):void{
						message.result = "sent";
						dispatchEvent(new PubNubEvent(PubNubEvent.PUBLISH_RESULT, message));
						p.unsubscribe({channel:channel});
					});

				},
				disconnect: function (message:Object):void {
					message.result="presence";
					dispatchEvent(new PubNubEvent(PubNubEvent.PUBLISH_RESULT, message));},
				error: function subscribeErrorHandler(e:Object):void {
					e.result="error";
				}
			});
		}
		private var currCountPublish:int=0;
		private var arrResult:Array = [];
		private var num:int = 8;
		public function multiplePublish(str:String):void
		{
			p = (cipher_key ? PubNubSecure.init : PubNub.init)(
				{	auth_key:	"x"	,
					cipher_key:	""	,
					origin:	"pubsub.pubnub.com",	
					publish_key:	"demo",	
					secret_key:	"demo",	
					ssl:	false	,
					subscribe_key:	"demo"
				}
			);
			
			var i:int;
			for(i=0;i<this.num;i++){
				mPublish(str,i);
			}
		}
		
		public function mPublish(str:String,currIndex:int):void {
			p.subscribe({
				backfill: false,
				noheresync: true,
				channel: channel+ String(currIndex),
				message: function subscribeMessageHandler(message:Object, envelope:Object, channel:String, time:Number):void {
				},
				presence: function subscribePresenceHandler(message:Object, here:*, channel:String, presenceChannel:String = null):void {

				},
				connect: function subscribeConnectHandler(channel:String):void {
					p.publish({
						channel: channel,
						message: { "data": str },
						auth_key: auth_key,
						error: function(message:Object):void{
							message.result = "publish error";
							p.unsubscribe({channel:channel});
							setResultMessage(message);
						}
					}, function(message:Object):void{
						message.result = "sent";
						p.unsubscribe({channel:channel});
						setResultMessage(message);
					});
				},
				disconnect: function (message:Object):void {
					message.result="presence";
					p.unsubscribe({channel:channel});
					setResultMessage(message);
				},
				error: function subscribeErrorHandler(e:Object):void {
					e.result="error";
					p.unsubscribe({channel:channel});
				}
			});
		}
		
		public function setResultMessage(obj:*):void{
			var isTrue:Boolean = false;
			if(obj is Object){
				isTrue = ("sent" == obj.result)? true:false;
			}else if(obj is String){
				isTrue = ("sent" == obj)? true:false;
			}
			
			arrResult.push(isTrue);
			
			if(arrResult.length == this.num){
				isTrue=true;
				for(var j:int = 0;j<arrResult.length;j++){
					if(!arrResult[j]){
						isTrue=false;
					}
				}
				var message:Object = new Object();
				if(obj is Object){
					obj.result=isTrue;
					message = obj;
				}else if(obj is String){
					message.result =isTrue;
				}
				
				dispatchEvent(new PubNubEvent(PubNubEvent.MULTIPLE_PUBLISH_RESULT, message));
			}
		}
		private var resultCount:int;
		public function history($resultCount:int = 0):void {
				this.resultCount=$resultCount;
			
			p = (cipher_key ? PubNubSecure.init : PubNub.init)(
				{	auth_key:	"x"	,
					cipher_key:	""	,
					origin:	"pubsub.pubnub.com",	
					publish_key:	"demo",	
					secret_key:	"demo",	
					ssl:	false	,
					subscribe_key:	"demo"
				}
			);
			channel = "channel_my_history"+Math.floor(Math.random()*100);
			p.subscribe({
				backfill: false,
				noheresync: true,
				channel:channel,
				message: function subscribeMessageHandler(message:Object, envelope:Object, channel:String, time:Number):void {
				},
				presence: function subscribePresenceHandler(message:Object, here:*, channel:String, presenceChannel:String = null):void {
					
				},
				connect: function subscribeConnectHandler(channel:String):void {
					onPublish(channel);
					onPublish(channel);
				},
				disconnect: function (message:Object):void {
					message.result="presence";
					p.unsubscribe({channel:channel});
				},
				error: function subscribeErrorHandler(e:Object):void {
					e.result="error";
					p.unsubscribe({channel:channel});
				}
			});
		}
		private var publishCount:int;
		private function onPublish(channel:String):void{
			p.publish({
				channel: channel,
				message: { "data": "mess" },
				auth_key: auth_key,
				error: function(message:Object):void{
					p.unsubscribe({channel:channel});
				}
			}, function(message:Object):void{
				message.result = "sent";
				p.unsubscribe({channel:channel});
				publishCount++;
				if(publishCount==2){
					if(resultCount!=0){
						setTimeout(onHistory2,10000,channel,resultCount);
					}else{
						setTimeout(onHistory,10000,channel);
					}
				}
			});	
		}
		private function onHistory(channel:String):void{
			
			p.history({
				channel: channel,
				callback: function (message:Array):void {
					trace(message[0].length);
					dispatchEvent(new PubNubEvent(PubNubEvent.HISTORY_RESULT1, {"result":message[0].length}));
				},
				error: function appendErrorToConsole(message:Object):void {
					message.result="error";
					dispatchEvent(new PubNubEvent(PubNubEvent.HISTORY_RESULT1, message));
				}
			});
			
		}
		private function onHistory2(channel:String,$resultCount:int):void{
			
			p.history({
				channel: channel,
				count: $resultCount,
				callback: function (message:Array):void {
					trace(message[0].length);
					dispatchEvent(new PubNubEvent(PubNubEvent.HISTORY_RESULT2, {"result":message[0].length}));
				},
				error: function appendErrorToConsole(message:Object):void {
					message.result="error";
					dispatchEvent(new PubNubEvent(PubNubEvent.HISTORY_RESULT2, message));
				}
			});
		}
		public function time():void
		{
			p = (cipher_key ? PubNubSecure.init : PubNub.init)(
				{	auth_key:	"x"	,
					cipher_key:	""	,
					origin:	"pubsub.pubnub.com",	
					publish_key:	"demo",	
					secret_key:	"demo",	
					ssl:	false	,
					subscribe_key:	"demo"
				}
			);
			
			p.subscribe({
				backfill: false,
				noheresync: true,
				channel: channel,
				message: function subscribeMessageHandler(message:Object, envelope:Object, channel:String, time:Number):void {
					dispatchEvent(new PubNubEvent(PubNubEvent.TIME_RESULT, message));
				},
				presence: function subscribePresenceHandler(message:Object, here:*, channel:String, presenceChannel:String = null):void {
					message.result="presence";
					dispatchEvent(new PubNubEvent(PubNubEvent.TIME_RESULT, message));
				},
				connect: function subscribeConnectHandler(channel:String):void {
					p.time(function timeCallBack(message:Object):void {
						var obj:Object = {};
						if(message != null) {obj.result = "ok";}
						else {obj.result = "error";}
						dispatchEvent(new PubNubEvent(PubNubEvent.TIME_RESULT, obj));
						p.unsubscribe({channel:channel});
					});
				},
				disconnect: function (message:Object):void {
					message.result="presence";
					dispatchEvent(new PubNubEvent(PubNubEvent.TIME_RESULT, message));},
				error: function subscribeErrorHandler(e:Object):void {
					e.result="error";
				}
			});
		}
		
		public function uuid():void
		{
			p = (cipher_key ? PubNubSecure.init : PubNub.init)(
				{	auth_key:	"x"	,
					cipher_key:	""	,
					origin:	"pubsub.pubnub.com",	
					publish_key:	"demo",	
					secret_key:	"demo",	
					ssl:	false	,
					subscribe_key:	"demo"
				}
			);
			
			p.subscribe({
				backfill: false,
				noheresync: true,
				channel: channel,
				message: function subscribeMessageHandler(message:Object, envelope:Object, channel:String, time:Number):void {
					dispatchEvent(new PubNubEvent(PubNubEvent.UUID_RESULT, message));
				},
				presence: function subscribePresenceHandler(message:Object, here:*, channel:String, presenceChannel:String = null):void {
					message.result="presence";
					dispatchEvent(new PubNubEvent(PubNubEvent.UUID_RESULT, message));
				},
				connect: function subscribeConnectHandler(channel:String):void {
					setTimeout(function uuidcall():void{
						p.uuid(function uuidCallBack(message:Object):void {
						var obj:Object = new Object();
						if(message != null) {obj.result = "ok";}
						else {obj.result = "error";}
						dispatchEvent(new PubNubEvent(PubNubEvent.UUID_RESULT, obj));
						p.unsubscribe({channel:channel});
					})}, 10000);
				},
				disconnect: function (message:Object):void {
					message.result="presence";
					dispatchEvent(new PubNubEvent(PubNubEvent.UUID_RESULT, message));},
				error: function subscribeErrorHandler(e:Object):void {
					e.result="error";
				}
			});
		}
		
		private function uuidCall():void{}
		
		public function hereNow():void
		{
			p = (cipher_key ? PubNubSecure.init : PubNub.init)(
				{	auth_key:	"x"	,
					cipher_key:	""	,
					origin:	"pubsub.pubnub.com",	
					publish_key:	"demo",	
					secret_key:	"demo",	
					ssl:	false	,
					subscribe_key:	"demo"
				}
			);
			
			p.subscribe({
				backfill: false,
				noheresync: true,
				channel: channel,
				message: function subscribeMessageHandler(message:Object, envelope:Object, channel:String, time:Number):void {
					dispatchEvent(new PubNubEvent(PubNubEvent.HERE_NOW_RESULT, message));
				},
				presence: function subscribePresenceHandler(message:Object, here:*, channel:String, presenceChannel:String = null):void {
					message.result="presence";
					dispatchEvent(new PubNubEvent(PubNubEvent.HERE_NOW_RESULT, message));
				},
				connect: function subscribeConnectHandler(channel:String):void {
					p.here_now({channel:channel}, function uuidCallBack(message:Object):void {
						message.result = message.occupancy;
						dispatchEvent(new PubNubEvent(PubNubEvent.HERE_NOW_RESULT, message));
						p.unsubscribe({channel:channel});
					});
				},
				disconnect: function (message:Object):void {
					message.result="presence";
					dispatchEvent(new PubNubEvent(PubNubEvent.HERE_NOW_RESULT, message));},
				error: function subscribeErrorHandler(e:Object):void {
					e.result="error";
				}
			});
		}
		
		public function grant():void
		{
			p = (cipher_key ? PubNubSecure.init : PubNub.init)(
				
				{	ssl:	false,
					origin            : 'pubsub.pubnub.com',
                    publish_key       : 'publish key goes here',
                    subscribe_key     : 'subscribe key',
                    secret_key        : 'secret key'
				}
			);
			
			var channel_1:String = channel + "-1";
			function grantError(message:Object):void{
				dispatchEvent(new PubNubEvent(PubNubEvent.RW_GRANT_RESULT, {result:"error"}));
			}
			
			p.grant({
				channel:channel_1,
				auth_key:auth_key,
				read : true,
				write : true,
				ttl : 100,
				callback:function grantCallback(message:Object):void{
					dispatchEvent(new PubNubEvent(PubNubEvent.RW_GRANT_RESULT, {result: message.message}));
				},
				error:grantError
			});
		}
		
		public function grantAudit():void
		{
			p = (cipher_key ? PubNubSecure.init : PubNub.init)(
				
				{	ssl:	false	,
					origin            : 'pubsub.pubnub.com',
				    publish_key       : 'publish key goes here',
					subscribe_key     : 'subscribe key',
					secret_key        : 'secret key'
				}
			);
			
			var channel_1:String = channel + "-1";
			function grantError(message:Object):void{
					dispatchEvent(new PubNubEvent(PubNubEvent.RW_GRANT_RESULT, {result:"error"}));
				}
			
			p.grant({
				channel:channel_1,
				auth_key:auth_key,
				read : true,
				write : true,
				ttl : 100,
				callback:function grantCallback(message:Object):void{
					if(message.status == 200) {
						p.audit({
							channel:channel_1,
							auth_key:auth_key,
							callback:function auditCallback(authMessage:Object):void{
								dispatchEvent(new PubNubEvent(PubNubEvent.RW_GRANT_AUDIT_RESULT, {result: message.message}));
							}
						});
					}
					else grantError("error");
				},
				error:grantError
			});
		}
		
		public function setUUID(value:String):void
		{
			p = (cipher_key ? PubNubSecure.init : PubNub.init)(
				
				{	auth_key:	"x"	,
					cipher_key:	""	,
					origin:	"pubsub.pubnub.com",	
					publish_key:	"demo",	
					secret_key:	"demo",	
					ssl:	false	,
					subscribe_key:	"demo"
				}
			);
			
			p.set_uuid(value);
			p.get_uuid(function getUUID(message:Object):void{
				var obj:Object = {}
				obj.result = message;
				dispatchEvent(new PubNubEvent(PubNubEvent.SET_UUID_RESULT, obj));
			});
		}
	}
}