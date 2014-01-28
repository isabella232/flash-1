package applicationTest
{
	import flash.events.Event;
	
	public class PubNubEvent extends Event
	{
		public static const SUBSCRIBE_RESULT:String = "SUBSCRIBE_RESULT";
		public static const PUBLISH_RESULT:String = "PUBLISH_RESULT";
		public static const MULTIPLE_PUBLISH_RESULT:String = "MULTIPLE_PUBLISH_RESULT";
		public static const TIME_RESULT:String = "TIME_RESULT";
		public static const UUID_RESULT:String = "UUID_RESULT";
		public static const SET_UUID_RESULT:String = "SET_UUID_RESULT";
		public static const HERE_NOW_RESULT:String = "HERE_NOW_RESULT";
		public static const HISTORY_RESULT1: String = "HISTORY_RESULT1";
		public static const HISTORY_RESULT2: String = "HISTORY_RESULT2";
		public static const GRUNT_RESULT:String = "GRUNT_RESULT";
		public static const RW_GRANT_RESULT:String = "RW_GRANT_RESULT";
		public static const RW_GRANT_AUDIT_RESULT:String = "RW_GRANT_AUDIT_RESULT";
		
		private var _obj:*;
		
		public function PubNubEvent(type:String,obj:* ,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.obj = obj;
		}

		public function get obj():*
		{
			return _obj;
		}

		public function set obj(value:*):void
		{
			_obj = value;
		}

	}
}