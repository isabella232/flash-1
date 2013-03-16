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
public class NonSubConnection extends Connection {

    protected var _timeout:int = Settings.NON_SUBSCRIBE_OPERATION_TIMEOUT;
    protected var nonSubTimer:int;
    protected var pendingConnection:Boolean;
    protected var initialized:Boolean
    private var busy:Boolean;

    public function NonSubConnection(timeout:int = Settings.NON_SUBSCRIBE_OPERATION_TIMEOUT) {
        super();
        _timeout = timeout;
    }

    override public function executeGet(operation:Operation):void {
        if (!operation) return;

        if (ready && _networkEnabled) {
            doSendOperation(operation);
        } else {

            operation.onError([0, Errors.NETWORK_UNAVAILABLE]);
            if (loader.connected == false) {
                loader.connect(operation.request);
            }
        }

        if (queue.indexOf(operation) == -1) {
            queue.push(operation);
        }
    }

    private function doSendOperation(operation:Operation):void {
        if (!operation) return;
        clearTimeout(nonSubTimer);
        var timeout:int = operation.timeout || _timeout;
        //trace('doSendOperation : ' + timeout, operation.url);
        nonSubTimer = setTimeout(onTimeout, operation.timeout, operation);
        busy = true;
        this.operation = operation;
        this.operation.startTime = getTimer();
        loader.load(operation);
    }

    private function onTimeout(operation:Operation):void {
        //trace(this, 'onTimeout');
        if (operation) {
            logError(operation);
            operation.onError({ message: Errors.OPERATION_TIMEOUT, operation: operation });
            removeOperation(operation);
        }
        this.operation = null;
        busy = false;
        sendNextOperation();
    }

    private function removeOperation(operation:Operation):void {
        var ind:int = queue.indexOf(operation);
        if (ind > -1) {
            queue.splice(ind, 1);
        }
    }

    override public function set networkEnabled(value:Boolean):void {
        super.networkEnabled = value;
        if (value) {
            reconnect();
        }
    }

    private function logError(operation:Operation):void {
        var args:Array = [Errors.OPERATION_TIMEOUT];
        var op:Operation = getLastOperation();
        if (op) {
            args.push(op.url);
        }
        Log.log(args.join(','), Log.ERROR);
    }

    private function sendNextOperation():void {
        if (queue.length > 0) {
            doSendOperation(queue.shift());
        }
    }

    override public function close():void {
        for each(var o:Operation  in queue) {
            o.destroy();
        }
        super.close();
        busy = false;
        initialized = false;
        clearTimeout(nonSubTimer);
    }

    public function reconnect():void {
        //trace(this, 'reconnect');
        busy = false;
        executeGet(queue[0]);
    }

    override protected function onConnect(e:Event):void {
        //trace('onConnect : ' + queue[0]);
        super.onConnect(e);
        doSendOperation(queue[0]);
    }

    override protected function get ready():Boolean {
        return super.ready && !busy;
    }

    override protected function onError(e:URLLoaderEvent):void {
        clearTimeout(nonSubTimer);
        dispatchEvent(new OperationEvent(OperationEvent.CONNECTION_ERROR, operation));
        super.onError(e);
    }

    override protected function onComplete(e:URLLoaderEvent):void {
        //trace('onComplete : ' + operation);
        clearTimeout(nonSubTimer);
        removeOperation(operation);
        super.onComplete(e);
        busy = false;
        operation = null;
        sendNextOperation();
    }
}
}