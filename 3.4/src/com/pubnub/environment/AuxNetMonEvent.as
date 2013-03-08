package com.pubnub.environment {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class AuxNetMonEvent extends Event {
		
		public static const HTTP_ENABLE:String = 'enable';
		public static const HTTP_DISABLE:String = 'disable';
		public static const MAX_RETRIES:String = 'max_retries';
		
		public function AuxNetMonEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new AuxNetMonEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("AuxNetMonEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}