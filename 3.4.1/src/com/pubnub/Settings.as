package com.pubnub {
     /**
      * ...
      * @author firsoff maxim, support@pubnub.com
      */
     public class Settings {

         // Sleep Settings
         public static const DETECT_SLEEP:Boolean = true;
         public static const SLEEP_THRESHOLD:int = 5000;

         // if panic_on_silence is true, will retry MAX_RECONNECT_RETRIES after SUB_NET_DOWN event,
         // waiting RECONNECT_RETRY_DELAY retries between reconnect attempts
         // if panic_on_silence is false, will retry indefinitely

         public static const ENABLE_MAX_RETRIES:Boolean = false;  // false = try forever. true = unsubscribe and disconnect after maximum retries
         public static const MAX_RECONNECT_RETRIES:uint = 60; // when this limit is hit, unsubscribe all, and connection.close()

         // If this is > 0, then retry to connect at this rate in ms. Otherwise, it will just retry at SUB_OP_TIMEOUT rate.
         public static const RECONNECT_RETRY_DELAY:uint = 1000;

         //
         public static const MAX_ERROR_DEBOUNCES:uint = 3;

         // if true, after reconnecting (after detecting disconnect), 'catches up' on missed messages upon reconnect

         public static const RESUME_ON_RECONNECT:Boolean = true;

         // Given the above defaults
         // the client would check for 5 minutes (300s) after network loss
         // ie, 100 times, every 3 seconds for a network connection

         // time in millseconds to wait for web server to return a response. DO NOT CHANGE unless requested by support
         public static const SUBSCRIBE_OPERATION_TIMEOUT:uint = 10000;
         public static const NON_SUBSCRIBE_OPERATION_TIMEOUT:uint = 15000;

     }
}
