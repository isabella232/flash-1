package com.pubnub.connection {
import com.pubnub.*;
import com.pubnub.environment.SystemMonitorEvent;
import com.pubnub.log.*;
import com.pubnub.operation.*;

import flash.events.*;
import flash.utils.*;

public class NonSubConnection extends Connection {

    public function NonSubConnection(timeout:int = Settings.NON_SUBSCRIBE_OPERATION_TIMEOUT) {
        _timeout = timeout;
        super();
    }

    override public function executeGet(operation:Operation):void {
        //trace("NonSubConnection.doSendOperation");
		super.executeGet(operation);
    }

    override protected function onConnect(e:Event):void {
        //trace("NonSubConnection: onConnect");
        dispatchEvent(new SystemMonitorEvent(SystemMonitorEvent.NON_SUB_NET_UP));
        super.onConnect(e);
    }


    override protected function onTimeout(operation:Operation):void {
        Log.log("NonSubConnection.onTimeout: " + operation.toString(), Log.DEBUG, operation);
		super.onTimeout(operation);
    }

    override public function close():void {
        Log.log("NonSubConnection.close");
        super.close();
    }

    override protected function onError(e:Event):void {
		//trace('NonSubscribeConnection onError');
        super.onError(e);
    }

    override protected function onClose(e:Event):void {
        //trace('NonSubscribeConnection onClose');
        super.onClose(e);
    }

    override protected function onComplete(e:Event):void {
        //trace('nonsubscribeConnection onComplete');

        if (_networkEnabled == false) {
            _networkEnabled = true
            dispatchEvent(new OperationEvent(OperationEvent.CONNECT, operation));
            dispatchEvent(new SystemMonitorEvent(SystemMonitorEvent.NON_SUB_NET_UP));
        }
        super.onComplete(e);
    }
}
}