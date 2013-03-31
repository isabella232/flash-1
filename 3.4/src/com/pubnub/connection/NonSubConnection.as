package com.pubnub.connection {
import com.pubnub.*;
import com.pubnub.environment.NetMonEvent;
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
        doSendOperation(operation);
    }

    override protected function onConnect(e:Event):void {
        trace("NonSubConnection: onConnect");
        dispatchEvent(new NetMonEvent(NetMonEvent.NON_SUB_NET_UP));
        super.onConnect(e);
    }

    override protected function doSendOperation(operation:Operation):void {
        trace("NonSubConnection.doSendOperation");
        super.doSendOperation(operation);
    }

    override protected function onTimeout(operation:Operation):void {
        super.onTimeout(operation);
        dispatchEvent(new OperationEvent(OperationEvent.TIMEOUT, operation));

        Log.log("NonSubConnection.onTimeout: " + operation.toString(), Log.DEBUG, operation);

        // TODO: Remove onError invokations
        //operation.onError({ message: Errors.OPERATION_TIMEOUT, operation: operation });
        this.close();
    }

    override public function close():void {

        Log.log("SubConnection.close");

        super.close();
    }

    override protected function onError(e:Event):void {
        super.onError(e);
    }

    override protected function onClose(e:Event):void {
        trace('subscribeConnection onClose');
        super.onClose(e);
    }

    override protected function onComplete(e:Event):void {
        trace('nonsubscribeConnection onComplete');

        if (_networkEnabled == false) {
            _networkEnabled = true
            dispatchEvent(new OperationEvent(OperationEvent.CONNECT, operation));
            dispatchEvent(new NetMonEvent(NetMonEvent.NON_SUB_NET_UP));
        }
        super.onComplete(e);
    }
}
}