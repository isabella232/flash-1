package com.pubnub.connection {
	import com.pubnub.*;
	import com.pubnub.log.*;
	import com.pubnub.net.*;
	import com.pubnub.operation.*;
	import flash.events.*;
	import flash.utils.*;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class HeartBeatConnection extends Connection {
		private var timeoutInterval:int;
		
		public function HeartBeatConnection() {
			super();
		}
		
		override public function executeGet(operation:Operation):void {
			super.executeGet(operation);
			var timeout:int = operation.timeout;
			clearTimeout(timeoutInterval);
			timeoutInterval = setTimeout(onTimeout, operation.timeout, operation);
			this.operation = operation;
			if (loader.connected) {
				loader.load(operation);
				this.operation.startTime = getTimer();
			}else {
				loader.connect(operation.request);
			}	
		}
		
		private function onTimeout(operation:Operation):void {
			if (operation) {
				Log.log(Errors.OPERATION_TIMEOUT + ', ' + operation.url);
				operation.onError( { message:Errors.OPERATION_TIMEOUT, operation:operation } );
			}
		}
		
		private function removeOperation(operation:Operation):void {
			var ind:int = queue.indexOf(operation);
			if (ind > -1) {
				clearTimeout(timeoutInterval);
				queue.splice(ind, 1);
			}
		}
		
		override protected function onComplete(e:URLLoaderEvent):void {
			super.onComplete(e);
			clearTimeout(timeoutInterval);
			operation = null;
		}
		
		override protected function onConnect(e:Event):void {
			//trace('onConnect : ' + operation);
			super.onConnect(e);
			if (operation) {
				executeGet(operation);
			}
		}	
	}
}