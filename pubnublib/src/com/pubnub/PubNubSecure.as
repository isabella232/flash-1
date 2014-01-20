package com.pubnub
{
	import flash.external.ExternalInterface;

	public class PubNubSecure extends PubNub
	{
		public function PubNubSecure(config:Object)
		{
			super(config);
		}

		override protected function createInstance(config:Object):void
		{
			ExternalInterface.call('PUBNUB_AS2JS_PROXY.createInstance', instanceId, config, true);
		}

		public static function init(config:Object):PubNub
		{
			return new PubNubSecure(config);
		}
	}
}
