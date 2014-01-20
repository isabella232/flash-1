package com.pubnub
{
	public class PubNub
	{			
		import flash.external.ExternalInterface;
		import flash.utils.ByteArray;
		
		import mx.utils.ObjectUtil;
		import mx.utils.UIDUtil;
		
		private static var allInstances:Object = {};
		private var callbacks:Object;
		private var heap:Object = {};
		private var readyState:Boolean;
		protected var instanceId:String;
		private static var jsProxyObjectName:String = 'PUBNUB_AS2JS_PROXY';
		
		private static var LEAVE_FIELDS:Array = ['callback', 'error'];
		private static var SETUP_FIELDS:Array = ['error', '_is_online', 'jsonp_cb', 'db' ]
		private static var HISTORY_FIELDS:Array = ['callback', 'error'];
		private static var REPLAY_FIELDS:Array = ['callback'];
		private static var PUBLISH_FIELDS:Array = ['callback', 'error'];
		private static var UNSUBSCRIBE_FIELDS:Array = ['callback', 'error'];
		private static var SUBSCRIBE_FIELDS:Array =
			['callback', 'message', 'connect', 'reconnect', 'disconnect', 'error', 'idle', 'presence'];
		private static var HERE_NOW_FIELDS:Array = ['callback', 'error', 'data'];
		private static var GRANT_FIELDS:Array = ['callback', 'error'];
		private static var REVOKE_FIELDS:Array = ['callback', 'error'];
		private static var AUDIT_FIELDS:Array = ['callback', 'error'];
		
		public function PubNub(config:Object) {
			instanceId = generateId();
			callbacks = {};
			readyState = false;
			
			setupCallbacks();
			PubNub.allInstances[instanceId] = this;
			
			createInstance(config);
		}

		protected function createInstance(config:Object):void
		{
			ExternalInterface.call('PUBNUB_AS2JS_PROXY.createInstance', instanceId, config);
		}

		public static function init(config:Object):PubNub
		{
			return new PubNub(config);
		}

		public static function secure(config:Object):PubNub
		{
			return new PubNubSecure(config);
		}
		
		public static function getInstanceById(instanceId:String):PubNub
		{
			return allInstances[instanceId];
		}
		
		public static function setupCallbacks():void {
			ExternalInterface.addCallback('created', createdHandler);
			ExternalInterface.addCallback('callback', callbackHandler);
			ExternalInterface.addCallback('error', errorHandler);
		}
		
		private function callCallback(callbackId:String, payload:Array):void {
			callbacks[callbackId].apply(this, payload);
		}
		
		// Handlers
		public static function createdHandler(instanceId:String):void {
			getInstanceById(instanceId).setReady();
		}
		
		public function setReady():void {
			readyState = true;
			
			for (var method:String in heap) {
				jsCall(method, heap[method]);
			}
		}
		
		public static function errorHandler(message:String):void {
			// TODO: throw error
		}
		
		public static function callbackHandler(instanceId:String, callbackId:String, payload:Array=undefined):void {
			getInstanceById(instanceId).callCallback(callbackId, payload);
		}
		
		// Actions
		public function history(args:Object, callback:Function=undefined):void {
			var callbackId:String = mockCallback(callback);
			var newArgs:Object = mockObjectCallbacks(args, PubNub.HISTORY_FIELDS);
			
			jsCall('history', [newArgs, callbackId]);
		}
		
		public function replay(args:Object):void {
			var newArgs:Object = mockObjectCallbacks(args, PubNub.REPLAY_FIELDS);
			
			jsCall('replay', [newArgs]);
		}
		
		public function subscribe(args:Object, callback:Function=undefined):void {
			var callbackId:String = mockCallback(callback);
			var newArgs:Object = mockObjectCallbacks(args, PubNub.SUBSCRIBE_FIELDS);
			
			jsCall('subscribe', [newArgs, callbackId]);
		}
		
		public function unsubscribe(args:Object, callback:Function=undefined):void {
			var callbackId:String = mockCallback(callback);
			var newArgs:Object = mockObjectCallbacks(args, PubNub.UNSUBSCRIBE_FIELDS);
			
			jsCall('unsubscribe', [newArgs, callbackId]);
		}
		
		public function publish(args:Object, callback:Function=undefined):void {
			var callbackId:String = mockCallback(callback);
			var newArgs:Object = mockObjectCallbacks(args, PubNub.PUBLISH_FIELDS);
			
			jsCall('publish', [newArgs, callbackId]);
		}
		
		public function here_now(args:Object, callback:Function=undefined):void {
			var callbackId:String = mockCallback(callback);
			var newArgs:Object = mockObjectCallbacks(args, PubNub.HERE_NOW_FIELDS);
			
			jsCall('here_now', [newArgs, callbackId]);
		}
		
		public function grant(args:Object, callback:Function=undefined):void {
			var callbackId:String = mockCallback(callback);
			var newArgs:Object = mockObjectCallbacks(args, PubNub.GRANT_FIELDS);
			
			jsCall('grant', [newArgs, callbackId]);
		}
		
		public function revoke(args:Object, callback:Function=undefined):void 
		{
			var callbackId:String = mockCallback(callback);
			var newArgs:Object = mockObjectCallbacks(args, PubNub.REVOKE_FIELDS);
			
			jsCall('revoke', [newArgs, callbackId]);
		}
		
		public function audit(args:Object, callback:Function=undefined):void 
		{
			var callbackId:String = mockCallback(callback);
			var newArgs:Object = mockObjectCallbacks(args, PubNub.AUDIT_FIELDS);
			
			jsCall('grant', [newArgs, callbackId]);
		}
		
		public function auth(auth:String):void {
			jsCall('auth', [auth]);
		}
		
		public function time(callback:Function):void {
			var callbackId:String = mockCallback(callback);
			jsCall('time', [callbackId]);
		}
		
		public function uuid(callback:Function):void {
			var callbackId:String = mockCallback(callback);
			// there is only argumetn, it's not array!!!
			jsCall('uuid', callbackId);
		}
		
		public function set_uuid(uuid:String):void {
			jsCall('set_uuid', [uuid]);
		}
		
		public function get_uuid(callback:Function):void {
			var callbackId:String = mockCallback(callback);
			// there is only argumetn, it's not array!!!
			jsCall('get_uuid', callbackId);
		}
		
		// Helpers
		private function mockObjectCallbacks(obj:Object, fields:Array):Object {
			var newObject:Object = ObjectUtil.copy(obj);
			var l:Number = fields.length;
			
			for (var i:int = 0; i < l; i++){
				var key:String = fields[i];
				if (obj.hasOwnProperty(key)) {
					newObject[key] = mockCallback(obj[key]);
				}
			}
			
			return newObject;
		}
		
		private function mockCallback(callback:Function=undefined):String {
			if ( null == callback ) return null;
			var id:String = PubNub.generateId();
			callbacks[id] = callback;
			return id;
		}
		
		public function jsCall(method:String, args:*):void {
			if (readyState) {
				ExternalInterface.call(
					PubNub.jsProxyObjectName + '.' + method,
					instanceId,
					args
				);
			} else {
				heap[method] = args;
			}
		}
		
		// Utils
		private static function generateId():String {
			return UIDUtil.createUID();
		}
		
		// TODO: remove this helper
		private static function cloneObject(source:Object):Object {
			var newBA:ByteArray = new ByteArray();
			newBA.writeObject(source);
			newBA.position = 0;
			return (newBA.readObject());
		}
	}
}
