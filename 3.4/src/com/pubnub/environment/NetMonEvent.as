package com.pubnub.environment {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class NetMonEvent extends Event {
		
		public static const HTTP_ENABLE:String = 'enable';
		public static const HTTP_DISABLE:String = 'disable';

        public static const SUBSCRIBE_TIMEOUT:String = 'subscribe_timeout';
        public static const SUBSCRIBE_TIMEIN:String = 'subscribe_timein';

		public static const MAX_RETRIES:String = 'max_retries';
		
		public function NetMonEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new NetMonEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("NetMonEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}