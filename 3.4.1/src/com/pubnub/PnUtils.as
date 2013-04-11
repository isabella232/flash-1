package com.pubnub {
	import flash.external.ExternalInterface;
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	public class PnUtils {
		private static const ALPHA_CHAR_CODES:Array = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70];

        public static function getUID():String {
			//get uuid formated xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
			var temp:Array = new Array(36);
			var i:int;

			for (i = 0 ; i < 35 ; i++ ) {
				if (i == 8 || i == 13 || i == 18 || i == 23 ) {
					temp[i] = 45;
				}
				else {
					temp[i] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
				}
			}
			
			return String.fromCharCode.apply(null, temp);
		}
		
		/**
		 * Encodes a string into some format
		 * Should be the escape function
		 * @param       args
		 * @return
		 */
		public static function encode(args:String):String{
			return encodeURIComponent(args);
			
		}
	}

}