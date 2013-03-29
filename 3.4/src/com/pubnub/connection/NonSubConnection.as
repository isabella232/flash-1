package com.pubnub.connection {
import com.pubnub.*;
import com.pubnub.environment.NetMonEvent;
import com.pubnub.log.*;
import com.pubnub.operation.*;

import flash.events.*;
import flash.utils.*;

public class NonSubConnection extends Connection {

    protected var initialized:Boolean
    private var reTryEnabled:Boolean;

    public function NonSubConnection(timeout:int = Settings.NON_SUBSCRIBE_OPERATION_TIMEOUT) {
        _timeout = timeout;
        super();
        this.reTryEnabled = true;
    }

    override public function executeGet(operation:Operation):void {
        doSendOperation(operation);
        super.doSendOperation(operation);
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
        dispatchEvent(new OperationEvent(OperationEvent.TIMEOUT, operation));

        Log.log("NonSubConnection.onTimeout: " + operation.toString(), Log.DEBUG, operation);

        // TODO: Remove onError invokations
        operation.onError({ message: Errors.OPERATION_TIMEOUT, operation: operation });
        this.operation = null;
        this.close();
    }

    override public function close():void {

        Log.log("SubConnection.close");

        super.close();
        initialized = false;
        clearTimeout(operationTimer);
    }

    override protected function onError(e:Event):void {
        clearTimeout(operationTimer);
        dispatchEvent(new OperationEvent(OperationEvent.CONNECTION_ERROR, operation));
        super.onError(e);
    }

    override protected function onClose(e:Event):void {
        trace('subscribeConnection onClose');
        clearTimeout(operationTimer);
        super.onClose(e);
    }

    override protected function onComplete(e:Event):void {
        trace('nonsubscribeConnection onComplete');

        if (_networkEnabled == false) {
            _networkEnabled = true
            dispatchEvent(new OperationEvent(OperationEvent.CONNECT, operation));
            dispatchEvent(new NetMonEvent(NetMonEvent.NON_SUB_NET_UP));
        }

        clearTimeout(operationTimer);
        super.onComplete(e);
        //this.operation = null;
    }
}
}