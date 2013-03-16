package com.pubnub {
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Errors {
		
		public static const OPERATION_TIMEOUT:String = 'OPERATION_TIMEOUT';
		public static const SYNC_CHANNEL_TIMEOUT:String = 'SYNC_CHANNEL_TIMEOUT';
		public static const RECONNECT_HEARTBEAT_TIMEOUT:String = 'RECONNECT_HEARTBEAT_TIMEOUT';
		static public const INIT_OPERATION_ERROR:String = "INIT_OPERATION_ERROR";
		static public const ALREADY_CONNECTED:String = "ALREADY_CONNECTED";
		static public const NOT_CONNECTED:String = "NOT_CONNECTED";

        static public const SUBSCRIBE_INIT_ERROR:String = "SUBSCRIBE_INIT_ERROR";
		static public const SUBSCRIBE_CHANNEL_TOO_BIG_OR_NULL:String = "Channel list is null or too big";
        static public const SUBSCRIBE_ALREADY_SUBSCRIBED:String = "Channel already subscribed";
        static public const SUBSCRIBE_CANT_UNSUB_NON_SUB:String = "Cannot unsubscribe: not subscribed";

        static public const SUBSCRIBE_CHANNEL_ERROR:String = "SUBSCRIBE_CHANNEL_ERROR";

		static public const NETWORK_RECONNECT_MAX_RETRIES_EXCEEDED:String = "NETWORK_RECONNECT_MAX_RETRIES_EXCEEDED";
		static public const NETWORK_RECONNECT_MAX_TIMEOUT_EXCEEDED:String = "NETWORK_RECONNECT_MAX_TIMEOUT_EXCEEDED";
		static public const NETWORK_UNAVAILABLE:String = "NETWORK_UNAVAILABLE";
		static public const NETWORK_LOST:String = "NETWORK_LOST";
		
	}

}