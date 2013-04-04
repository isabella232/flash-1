package com.pubnub.environment {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class SystemMonitorEvent extends Event {
		
		public static const RESTORE_FROM_SLEEP:String = 'restore_from_sleep';

        public static const SUB_NET_DOWN:String = 'sub_net_down';
        public static const SUB_NET_UP:String = 'sub_net_up';

        public static const NON_SUB_NET_DOWN:String = 'non_sub_net_down';
        public static const NON_SUB_NET_UP:String = 'non_sub_net_up'
		
		private var _timeout:int = 0;
		
		public function SystemMonitorEvent(type:String, timeout:int = 0) {
			super(type);
			_timeout = timeout;
		} 
		
		public override function clone():Event { 
			return new SystemMonitorEvent(type, timeout);
		} 
		
		public override function toString():String { 
			return formatToString("SysMonEvent", "type", "timeout", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get timeout():int {
			return _timeout;
		}
		
	}
	
}