package com.pubnub.connection {
//import com.pubnub.net.*;
//import com.pubnub.net.URLLoaderEvent;
import com.pubnub.operation.*;

import flash.events.*;
import flash.net.URLLoader;
import flash.utils.clearTimeout;
import flash.utils.getTimer;
import flash.utils.setTimeout;

/**
 * ...
 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
 */
public class Connection extends EventDispatcher {
    protected var loader:URLLoader;
    protected var _destroyed:Boolean;
    protected var operation:Operation;
    protected var _networkEnabled:Boolean;
    protected var operationTimer:int;
    protected var _timeout:int;



    public function Connection() {
        init();
    }

    protected function init():void {
        _networkEnabled = false;
        loader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onComplete)
        loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
        loader.addEventListener(Event.CONNECT, onConnect);
        loader.addEventListener(Event.CLOSE, onClose);
    }

    protected function onClose(e:Event):void {
        _networkEnabled = false;
        dispatchEvent(e);
    }

    protected function get ready():Boolean {
        return loader
    }

    protected function doSendOperation(operation:Operation):void {
        clearTimeout(operationTimer);
        operationTimer = setTimeout(onTimeout, _timeout, operation);

        this.operation = operation;
        this.operation.startTime = getTimer();
        loader.load(operation.request);
    }

    protected function onConnect(e:Event):void {
        // abstract
        _networkEnabled = true;
        dispatchEvent(new OperationEvent(OperationEvent.CONNECT, operation));
    }

    protected function onError(e:Event):void {
        _networkEnabled = false;
    }

    protected function onTimeout(operation:Operation):void {
        _networkEnabled = false;
    }

    protected function onComplete(e:Event):void {
        _networkEnabled = true;

        if (operation && !operation.destroyed && loader.data) {
            operation.onData(loader.data);
        }
    }

    public function executeGet(operation:Operation):void {
        //this.operation = operation;
    }

    public function getLastOperation():Operation {
        return operation;
    }

    public function destroy():void {
        if (_destroyed) return;
        loader.removeEventListener(Event.COMPLETE, onComplete)
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
        loader.removeEventListener(Event.CONNECT, onConnect);
        loader.removeEventListener(Event.CLOSE, onClose);
        close();
        loader.close();
        loader = null;

        _destroyed = true;
        operation = null;
    }

    public function close():void {

        operation = null;
        try {
            loader.close();
        } catch (e) {
            if (e.errorID == 2029) {
                trace("Will not close because the connection is not open.")
            } else {
                trace("Unknown connection close error: " + e.message)
            }

        }

    }

    public function get connected():Boolean {
        return loader;
    }

    public function get destroyed():Boolean {
        return _destroyed;
    }

    public function get networkEnabled():Boolean {
        return _networkEnabled;
    }

    public function set networkEnabled(value:Boolean):void {
        _networkEnabled = value;
    }
}
}