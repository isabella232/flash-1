package com.pubnub.connection {
import com.pubnub.Settings;
import com.pubnub.log.Log;
import com.pubnub.operation.Operation;
import com.pubnub.operation.OperationEvent;

import flash.events.Event;
import flash.net.*;


public class SubscribeConnection extends Connection {

    public function SubscribeConnection(timeout:int = Settings.SUBSCRIBE_OPERATION_TIMEOUT) {
        _timeout = timeout;

        // You must set the compiler option
        // -define=CONFIG::AIR,false if you are not running Air
        // -define=CONFIG::AIR,true if you are running Air

        CONFIG::AIR {
            URLRequestDefaults.idleTimeout = _timeout;
        }

        super();
    }

    override public function executeGet(operation:Operation):void {
        //trace("SubConnection.doSendOperation");
        super.executeGet(operation);
    }

    override protected function onConnect(e:Event):void {
        //trace("SubscribeConnection: onConnect");
        super.onConnect(e);
    }


    override protected function onTimeout(operation:Operation):void {
        Log.log("SubConnection.onTimeout: " + operation.toString(), Log.DEBUG, operation);
        super.onTimeout(operation);
    }

    override public function close():void {
        Log.log("SubConnection.close");
        super.close();
    }

    override protected function onError(e:Event):void {
        //trace('subscribeConnection onError');
        super.onError(e);
    }

    override protected function onClose(e:Event):void {
        //trace('subscribeConnection onClose');
        super.onClose(e);
    }

    override protected function onComplete(e:Event):void {
        //trace('subscribeConnection onComplete');

        if (_networkEnabled == false) {
            _networkEnabled = true
            dispatchEvent(new OperationEvent(OperationEvent.CONNECT, [1, "connection up to server"]));
        }
        super.onComplete(e);
    }
}
}
