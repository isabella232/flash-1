package com.pubnub.operation
{
	import com.pubnub.PnUtils;
	import com.pubnub.Settings;
	
	import flash.net.URLRequest;

	public class HereNowOperation extends Operation
	{
        public var _channel:String;
        public var sub_key:String;
        public var cipherKey:String;
        public function HereNowOperation(origin:String)
        {
            super(origin, timeout);
        }
		
        override public function setURL(url:String = null, args:Object = null):URLRequest{
            _channel = args.channel;
            sub_key = args['sub-key'];
            url = _origin + "/v2/presence/sub-key/" + sub_key + "/channel/" + PnUtils.encode(_channel);
            return super.setURL(url, args);
        }
    }
}