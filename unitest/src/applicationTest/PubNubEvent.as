package applicationTest {
    import flash.events.Event;

    public class PubNubEvent extends Event {
        public static const SUBSCRIBE_RESULT:String = "SUBSCRIBE_RESULT";
        public static const PUBLISH_RESULT:String = "PUBLISH_RESULT";
        public static const MULTIPLE_PUBLISH_RESULT:String = "MULTIPLE_PUBLISH_RESULT";
        public static const TIME_RESULT:String = "TIME_RESULT";
        public static const UUID_RESULT:String = "UUID_RESULT";
        public static const SET_UUID_RESULT:String = "SET_UUID_RESULT";
        public static const HERE_NOW_RESULT:String = "HERE_NOW_RESULT";
        public static const WHERE_NOW_RESULT:String = "WHERE_NOW_RESULT";
        public static const HISTORY_RESULT_1:String = "HISTORY_RESULT_1";
        public static const HISTORY_RESULT_2:String = "HISTORY_RESULT_2";
        public static const GRUNT_RESULT:String = "GRUNT_RESULT";
        public static const RW_GRANT_RESULT:String = "RW_GRANT_RESULT";
        public static const RW_GRANT_AUDIT_RESULT:String = "RW_GRANT_AUDIT_RESULT";
        public static const NOT_EXPECTED_ERROR:String = "NOT_EXPECTED_ERROR";
        public static const CG_GET_CHANNELS:String = "CG_GET_CHANNELS";
        public static const CG_GET_GROUPS:String = "CG_GET_GROUPS";
        public static const CG_ADD:String = "CG_ADD";
        public static const CG_REMOVE_CHANNEL:String = "CG_REMOVE_CHANNEL";
        public static const CG_REMOVE_GROUP:String = "CG_REMOVE_GROUP";
        public static const ERROR:String = "ERROR";

        private var _result:*;

        public function PubNubEvent(kind:String, obj:*, bubbles:Boolean = false, cancelable:Boolean = false) {
            super(kind, bubbles, cancelable);
            this.result = obj;
        }

        public function get result():* {
            return _result;
        }

        public function set result(value:*):void {
            _result = value;
        }

    }
}