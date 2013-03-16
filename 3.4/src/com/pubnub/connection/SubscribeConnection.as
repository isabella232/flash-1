package com.pubnub.connection {
import com.pubnub.log.Log;
import com.pubnub.net.URLLoaderEvent;
import com.pubnub.operation.Operation;
import com.pubnub.operation.OperationEvent;
import com.pubnub.Settings;
import com.pubnub.subscribe.SubscribeEvent;

import flash.events.Event;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

/**
 * ...
 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
 */
public class SubscribeConnection extends Connection {

    protected var timeout:int;

    override protected function init():void {
        super.init();
    }

    override public function executeGet(operation:Operation):void {
        super.executeGet(operation);
        if (ready) {
            doSendOperation(operation);
        } else {
            Log.log("executeGet: connection not ready for op: " + operation.toString(), Log.DEBUG);
            loader.connect(operation.request);
            queue.push(operation);
        }
    }

    override protected function onConnect(e:Event):void {
        trace("subscribe connection: onConnect");
        dispatchEvent(new OperationEvent(OperationEvent.CONNECT, operation));

        if (queue.length > 0) {
            for (var i:int = 0; i < queue.length; i++) {
                executeGet(queue[i]);
            }
            queue.length = 0;
        }
    }

    override protected function get ready():Boolean {
        return loader.ready;
    }

    private function doSendOperation(operation:Operation):void {
        //trace('doSendOperation');
        clearTimeout(timeout);
        timeout = setTimeout(onTimeout, Settings.OPERATION_TIMEOUT, operation);
        this.operation = operation;
        loader.load(operation);
    }

    private function onTimeout(operation:Operation):void {
        trace('subscribeConnection onTimeout');
        dispatchEvent(new OperationEvent(OperationEvent.TIMEOUT, operation));
        Log.log("Operation timeout: " + operation.toString(), Log.DEBUG, operation);
    }

    override public function close():void {
        clearTimeout(timeout);
        super.close();
    }

    override protected function onError(e:URLLoaderEvent):void {
        clearTimeout(timeout);
        dispatchEvent(new OperationEvent(OperationEvent.CONNECTION_ERROR, operation));
        super.onError(e);
    }

    override protected function onClose(e:Event):void {
        trace('onClose');
        clearTimeout(timeout);
        super.onClose(e);
    }
}
}