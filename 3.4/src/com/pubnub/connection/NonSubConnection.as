package com.pubnub.connection {
import com.pubnub.*;
import com.pubnub.environment.NetMonEvent;
import com.pubnub.log.*;
import com.pubnub.net.*;
import com.pubnub.operation.*;

import flash.events.*;
import flash.utils.*;

public class NonSubConnection extends Connection {

    protected var _timeout:int = Settings.NON_SUBSCRIBE_OPERATION_TIMEOUT;
    protected var nonSubTimer:int;
    protected var initialized:Boolean
    private var busy:Boolean;
    private var reTryEnabled:Boolean;

    public function NonSubConnection(timeout:int = Settings.NON_SUBSCRIBE_OPERATION_TIMEOUT) {
        super();
        _timeout = timeout;
        this.reTryEnabled = true;
    }

    override public function executeGet(operation:Operation):void {
        doSendOperation(operation);
    }

    override protected function onConnect(e:Event):void {
        trace("NonSubConnection: onConnect");
        dispatchEvent(new NetMonEvent(NetMonEvent.NON_SUB_NET_UP));
        _networkEnabled = true;
        super.onConnect(e);

        if (queue && queue[0]) {
            executeGet(queue[0]);
            queue.length = 0;
        }
    }

    override protected function get ready():Boolean {
        return super.ready && !busy;
    }

    private function doSendOperation(operation:Operation):void {
        if (!operation) {
            trace("NonSubConnection.doSendOperation: operation is null.");
            return;
        }

        clearTimeout(nonSubTimer);

        nonSubTimer = setTimeout(onTimeout, _timeout, operation);
        busy = true;

        this.operation = operation;
        this.operation.startTime = getTimer();
        trace("doSendOperation startTime:" + this.operation.startTime.toString());
        loader.load(operation.request);
    }

    private function onTimeout(operation:Operation):void {
        var tmpOperation:Operation = new Operation(operation.origin, operation.timeout);
        tmpOperation.setURL(operation.url);

        dispatchEvent(new NetMonEvent(NetMonEvent.NON_SUB_NET_DOWN));
        Log.log("NonSubConnection.onTimeout: " + operation.toString(), Log.DEBUG, operation);

        if (reTryEnabled) {
            reTryEnabled = false;
            operation.onError({ reTry: true, message: Errors.OPERATION_TIMEOUT, operation: operation });
        } else {
            operation.onError({ message: Errors.OPERATION_TIMEOUT, operation: operation });
        }
        this.operation = null;
        busy = false;
        this.close();
    }

    override public function close():void {
        if (queue && queue[0]) {
            queue[0].destroy();
        }

        super.close();
        busy = false;
        initialized = false;
        clearTimeout(nonSubTimer);
    }

    override protected function onError(e:Event):void {
        _networkEnabled = false;
        clearTimeout(nonSubTimer);
        dispatchEvent(new OperationEvent(OperationEvent.CONNECTION_ERROR, operation));
        super.onError(e);
    }

    override protected function onClose(e:Event):void {
        trace('subscribeConnection onClose');
        clearTimeout(nonSubTimer);
        super.onClose(e);
    }

    override protected function onComplete(e:Event):void {
        dispatchEvent(new NetMonEvent(NetMonEvent.NON_SUB_NET_UP));
        clearTimeout(nonSubTimer);
        super.onComplete(e);
        busy = false;
        this.operation = null;
    }
}
}