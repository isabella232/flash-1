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

    public function NonSubConnection(timeout:int = Settings.NON_SUBSCRIBE_OPERATION_TIMEOUT) {
        super();
        _timeout = timeout;
    }

    override public function executeGet(operation:Operation):void {
        if (!operation) {
            trace("NonSubConnection.executeGet: operation is null.");
            return;
        }

        if (ready && _networkEnabled) {
            Log.log("NonSubConnection.executeGet: ready for: " + operation.toString(), Log.DEBUG);
            doSendOperation(operation);
        } else {
            Log.log("NonSubConnection.executeGet: not ready trying to restart loader for: " + operation.toString(), Log.DEBUG);
            if (loader.connected == false) {
                loader.connect(operation.request);
            }
        }

        queue[0] = operation;

    }

    override protected function onConnect(e:Event):void {
        trace("NonSubConnection: onConnect");
        dispatchEvent(new NetMonEvent(NetMonEvent.NON_SUB_NET_UP, operation));
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
        loader.load(operation);
    }

    private function onTimeout(operation:Operation):void {
        dispatchEvent(new NetMonEvent(NetMonEvent.NON_SUB_NET_DOWN, operation));
        Log.log("NonSubConnection.onTimeout: " + operation.toString(), Log.DEBUG, operation);

        operation.onError({ message: Errors.OPERATION_TIMEOUT, operation: operation });

        this.operation = null;
        busy = false;
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

    override protected function onError(e:URLLoaderEvent):void {
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

    override protected function onComplete(e:URLLoaderEvent):void {
        dispatchEvent(new NetMonEvent(NetMonEvent.NON_SUB_NET_UP, operation));
        clearTimeout(nonSubTimer);
        super.onComplete(e);
        busy = false;
        this.operation = null;
    }
}
}