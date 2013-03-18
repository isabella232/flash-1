package com.pubnub {
     /**
      * ...
      * @author firsoff maxim, support@pubnub.com
      */
     public class Settings {
         // retry to connect a maximum of this many times before Pn.shutdown()
         public static const MAX_RECONNECT_RETRIES:uint = 500; //100;
         public static const RECONNECT_RETRY_DELAY:uint = 3000; //100;

         // should we send a "NetMon.SUB_NET_UP" when we connect to a PubNub server?
         // if not, only PnEvent.Subscribe will setting "NetMon.SUB_NET_UP"
         public static const SUB_NET_UP_ON_TCP_CONNECT:Boolean = false;

         // if true, after reconnecting (after detecting disconnect), 'catches up' on missed messages upon reconnect

         public static const RESUME_ON_RECONNECT:Boolean = true;

         // Given the above defaults
         // the client would check for 5 minutes (300s) after network loss
         // ie, 100 times, every 3 seconds for a network connection

         // time in millseconds to wait for web server to return a response. DO NOT CHANGE unless requested by support
         public static const SUBSCRIBE_OPERATION_TIMEOUT:uint = 300000;
         public static const NON_SUBSCRIBE_OPERATION_TIMEOUT:uint = 5000;

         /////////////////////////////////////////////////////////////////////////////

         // First level net test before subscribe is on, Using below POT as timeout
         // Do not exceed 15000 !!!!

         public static const PING_OPERATION_INTERVAL:uint = 15000;
         public static const REMOTE_OPERATION_INTERVAL:uint = 5000;

         // Timeout, in ms, for above POI
         public static const PING_OPERATION_TIMEOUT:uint = 10000;
         public static const REMOTE_OPERATION_TIMEOUT:uint = 3000;

         ////////////////////////////////////////////////////////////////////////////
		 
		 // When in subscribe recovery mode, try to hit POU endpoint every PORI ms
		 public static const PING_OPERATION_RETRY_INTERVAL:uint = 1000;
         public static const REMOTE_OPERATION_RETRY_INTERVAL:uint = 1000;

         // URL Endpoint for recovery mode net detection

         //public static const PING_OPERATION_URL:String = 'http://pubsub.pubnub.com/time/0';
         //public static const REMOTE_OPERATION_URL:String = 'http://localhost:3000/';

         public static const REMOTE_OPERATION_URL:String = 'http://pubsub.pubnub.com/time/0';
         public static const PING_OPERATION_URL:String = 'http://localhost:3000/';

         //public static const REMOTE_OPERATION_URL:String = 'http://pubsub.pubnub.com/crossdomain.xml';



     }
}
