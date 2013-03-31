package com.pubnub.connection {
import com.pubnub.*;
import com.pubnub.environment.NetMonEvent;
import com.pubnub.log.*;
import com.pubnub.operation.*;

import flash.events.Event;
import flash.utils.clearTimeout;
import flash.utils.getTimer;
import flash.utils.setTimeout;

public class SubscribeConnection extends Connection {

    public function SubscribeConnection(timeout:int = Settings.SUBSCRIBE_OPERATION_TIMEOUT) {
        _timeout = timeout;
        super();
    }

    override public function executeGet(operation:Operation):void {
        doSendOperation(operation);
    }

    override protected function onConnect(e:Event):void {
        // TODO: Why doesn't this fire?
        trace("SubscribeConnection: onConnect");
        dispatchEvent(new OperationEvent(OperationEvent.CONNECT, operation));
        super.onConnect(e);
    }

    override protected function doSendOperation(operation:Operation):void {
        trace("SubConnection.doSendOperation");
        super.doSendOperation(operation);
    }

    override protected function onTimeout(operation:Operation):void {
        super.onTimeout(operation);
        dispatchEvent(new OperationEvent(OperationEvent.TIMEOUT, operation));

        Log.log("SubConnection.onTimeout: " + operation.toString(), Log.DEBUG, operation);

        // TODO: Remove onError invokations
        //operation.onError({ message: Errors.OPERATION_TIMEOUT, operation: operation });
    }

    override public function close():void {

        Log.log("SubConnection.close");
        super.close();
    }

    override protected function onError(e:Event):void {
        trace('subscribeConnection onError');
        dispatchEvent(new OperationEvent(OperationEvent.CONNECTION_ERROR, operation));
        super.onError(e);
    }

    override protected function onClose(e:Event):void {
        trace('subscribeConnection onClose');
        super.onClose(e);
    }

    override protected function onComplete(e:Event):void {
        trace('subscribeConnection onComplete');

        if (_networkEnabled == false) {
            _networkEnabled = true
            dispatchEvent(new OperationEvent(OperationEvent.CONNECT, [1, "connection up to server"]));
        }
        super.onComplete(e);
    }
}
}