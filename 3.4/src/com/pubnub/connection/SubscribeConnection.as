package com.pubnub.connection {
import com.pubnub.Errors;
import com.pubnub.environment.NetMonEvent;
import com.pubnub.log.Log;
import com.pubnub.net.URLLoaderEvent;
import com.pubnub.operation.Operation;
import com.pubnub.operation.OperationEvent;
import com.pubnub.Settings;

import flash.events.Event;
import flash.utils.clearTimeout;
import flash.utils.getTimer;
import flash.utils.setTimeout;

public class SubscribeConnection extends Connection {

    protected var _timeout:int;
    protected var subTimer:int;
    protected var initialized:Boolean;

    public function SubscribeConnection(timeout:int = Settings.SUBSCRIBE_OPERATION_TIMEOUT) {
        super();
        _timeout = timeout;
    }

    override public function executeGet(operation:Operation):void {
        doSendOperation(operation);
    }

    override protected function onConnect(e:Event):void {
        trace("SubscribeConnection: onConnect");
        dispatchEvent(new NetMonEvent(NetMonEvent.SUB_NET_UP));
        super.onConnect(e);
    }

    override protected function get ready():Boolean {
        return super.ready
    }

    private function doSendOperation(operation:Operation):void {
        trace("SubConnection.doSendOperation");

        if (!operation) {
            trace("SubConnection.doSendOperation: operation is null.");
            return;
        }

        clearTimeout(subTimer);
        subTimer = setTimeout(onTimeout, _timeout, operation);

        this.operation = operation;
        this.operation.startTime = getTimer();
        loader.load(operation.request);
    }

    private function onTimeout(operation:Operation):void {
        dispatchEvent(new OperationEvent(OperationEvent.TIMEOUT, operation));
        Log.log("SubConnection.onTimeout: " + operation.toString(), Log.DEBUG, operation);

        operation.onError({ message: Errors.OPERATION_TIMEOUT, operation: operation });

        this.operation = null;
    }

    override public function close():void {

        Log.log("SubConnection.close");

        if (queue && queue[0]) {
            queue[0].destroy();
        }

        super.close();
        initialized = false;
        clearTimeout(subTimer);
    }

    override protected function onError(e:Event):void {
        trace('subscribeConnection onError');
        _networkEnabled = false;
        clearTimeout(subTimer);
        dispatchEvent(new OperationEvent(OperationEvent.CONNECTION_ERROR, operation));
        super.onError(e);
    }

    override protected function onClose(e:Event):void {
        trace('subscribeConnection onClose');
        clearTimeout(subTimer);
        super.onClose(e);
    }

    override protected function onComplete(e:Event):void {
        trace('subscribeConnection onComplete');

        dispatchEvent(new NetMonEvent(NetMonEvent.SUB_NET_UP));
        clearTimeout(subTimer);
        super.onComplete(e);
        //this.operation = null;
    }
}
}