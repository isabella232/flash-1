package com.pubnub.operation {
	//import com.pubnub.net.URLRequest;
	import com.pubnub.PnUtils;
	import com.pubnub.Settings;
	
	import flash.net.URLRequest;

 /**
	 * ...
	 * @author geremy cohen, geremy@pubnub.com
 */

	public class HereNowOperation extends Operation {
		
		public var channel:String = ""; 
		public var uuid:String = ""; 
		public var subscribeKey:String = ""; 
		
		public function HereNowOperation (origin:String, timeout:int = 0) {
			super(origin);
			if (timeout > 0 && timeout < Settings.NON_SUBSCRIBE_OPERATION_TIMEOUT) {
				_timeout = timeout;
			}
		}
		
		override public function setURL(url:String = null, args:Object = null):URLRequest {
			url = _origin + "/v2/presence/sub_key/" + subscribeKey + "/channel/" + PnUtils.encode(channel);
			if (uuid.length > 0) {
				url += '?uuid=' + uuid;
			}
			
			return super.setURL(url, args);
		}
	}
}