package com.pubnub.environment {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class NetMonEvent extends Event {
		
        public static const SUB_NET_DOWN:String = 'sub_net_down';
        public static const SUB_NET_UP:String = 'sub_net_up';

        public static const NON_SUB_NET_DOWN:String = 'non_sub_net_down';
        public static const NON_SUB_NET_UP:String = 'non_sub_net_up'

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