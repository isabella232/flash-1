package com.pubnub.connection {
	//import com.pubnub.net.*;
//import com.pubnub.net.URLLoaderEvent;
import com.pubnub.operation.*;
	import flash.events.*;
import flash.net.URLLoader;

/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Connection extends EventDispatcher {
		protected var loader:URLLoader;
		protected var _destroyed:Boolean;
		protected var queue:/*Operation*/Array;
		protected var operation:Operation;
		protected var _closed:Boolean;
		protected var _networkEnabled:Boolean;
		
		public function Connection() {
			init();
		}
		
		protected function init():void {
			queue = [];
            _networkEnabled = false;
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, 	onComplete)
			loader.addEventListener(IOErrorEvent.IO_ERROR, 		onError);
			loader.addEventListener(Event.CONNECT, 				onConnect);
			loader.addEventListener(Event.CLOSE, 				onClose);
		}
		
		protected function onClose(e:Event):void {
			dispatchEvent(e);
		}
		
		protected function get ready():Boolean{
			return loader
		}
		
		protected function onConnect(e:Event):void {
			// abstract
			_closed = false;
            _networkEnabled = true;
		}
		
		protected function onError(e:Event):void {
			// abstract
		}
		
		protected function onComplete(e:Event):void {
			//var response:URLResponse = e.data as URLResponse;
			if (operation && !operation.destroyed && loader.data ) {
				operation.onData(loader.data);
			}
		}
		
		public function executeGet(operation:Operation):void {
			//this.operation = operation;
		}
		
		public function getLastOperation():Operation{
			return operation;
		}
		
		public function destroy():void {
			if (_destroyed) return;
			loader.removeEventListener(Event.COMPLETE, onComplete)
			loader.removeEventListener(IOErrorEvent.IO_ERROR, 	onError);
			loader.removeEventListener(Event.CONNECT, 			onConnect);
			loader.removeEventListener(Event.CLOSE, 			onClose);
			close();
			loader.close();
			loader = null;
			
			_destroyed = true;
			queue = null;
			operation = null;
		}
		
		public function close():void {
			_closed = true;
			queue.length = 0;
			operation = null;
            try {
                loader.close();
            } catch(e) {
                if (e.errorID == 2029) {
                    trace("Will not close because the connection is not open.")
                } else {
                    trace("Unknown connection close error: " + e.message)
                }

            }

		}
		
		public function get connected():Boolean{
			return loader;
		}
		
		public function get destroyed():Boolean {
			return _destroyed;
		}
		
		public function get networkEnabled():Boolean {
			return _networkEnabled;
		}
		
		public function set networkEnabled(value:Boolean):void {
			_networkEnabled = value;
		}
	}
}