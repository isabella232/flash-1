package com.pubnub {

import com.pubnub.connection.*;
import com.pubnub.environment.*;
import com.pubnub.log.*;
import com.pubnub.operation.*;
import com.pubnub.operation.OperationEvent;
import com.pubnub.subscribe.*;

import flash.errors.*;
import flash.events.*;
import flash.utils.setTimeout;


// refactoring of this file will include consolidation of
// Environment.as, NetMon.as SysMon.as

use namespace pn_internal;

[Event(name="initError", type="com.pubnub.PnEvent")]
[Event(name="init", type="com.pubnub.PnEvent")]
public class Pn extends EventDispatcher {
    static private var __instance:Pn;

    /*private var _initialized:Boolean = false;	// gut out unused code*/

    private var subscribeObject:Subscribe;

    private var _origin:String;
    private var _ssl:Boolean;
    private var _publishKey:String = "demo";
    private var _subscribeKey:String = "demo";
    private var secretKey:String = "";
    private var cipherKey:String = "";

    private var _sessionUUID:String = "";
    private var environment:Environment;

    static pn_internal var nonSubConnection:NonSubConnection;

    public function Pn() {
        if (__instance) throw new IllegalOperationError('Use [Pn.instance] getter');
        setup();
    }

    private function setup():void {

        // This should be a singleton class
		
        Pn.nonSubConnection = new NonSubConnection(Settings.NON_SUBSCRIBE_OPERATION_TIMEOUT);

		Pn.nonSubConnection.addEventListener(NetMonEvent.NON_SUB_NET_UP, onNonSubNet);
        Pn.nonSubConnection.addEventListener(NetMonEvent.NON_SUB_NET_DOWN, onNonSubNet);

        Pn.nonSubConnection.addEventListener(OperationEvent.TIMEOUT, onNonSubOp);
        Pn.nonSubConnection.addEventListener(OperationEvent.CONNECT, onNonSubOp);


        // For every Pn instance, there should be two singleton connections:
        // SubscribeConnection, and NonSubscribeConnection

        // environment stuff -- this can probably be rolled into another class

        environment = new Environment(origin);
        environment.addEventListener(EnvironmentEvent.RECONNECT, onEnvironmentReconnect);
    }

    // these are handlers for nonSubscribeConnection network events
    private function onNonSubNet(e:NetMonEvent):void {
        trace("PN.onNonSubNet: " + e);
        dispatchEvent(e);
    }

    private function onNonSubOp(e:OperationEvent):void {
        trace("PN.onNonSubOp: " + e);
        dispatchEvent(e);
    }

    public static function get instance():Pn {
        __instance ||= new Pn();
        return __instance;
    }

    public static function init(config:Object):void {
        instance.init(config);
    }

    public function init(config:Object):void {


        _ssl = config.ssl;
        origin = config.origin;

        _sessionUUID ||= PnUtils.getUID();

        environment.start();
		if (subscribeObject) {
			subscribeObject.unsubscribeAll();
		}

        subscribeObject ||= new Subscribe(origin);

        addSubscribeEventListeners();

        subscribeObject.origin = _origin;
        subscribeObject.UUID = _sessionUUID;

        if (config.publish_key)
            _publishKey = config.publish_key;

        if (config.sub_key)
            _subscribeKey = config.sub_key;
        subscribeObject.subscribeKey = _subscribeKey;

        if (config.secret_key)
            secretKey = config.secret_key;
        subscribeObject.secretKey = secretKey;


        if (config.cipher_key)
            cipherKey = config.cipher_key;
        subscribeObject.cipherKey = cipherKey;

        time(); // warm the non-sub connection
    }

    // adding listeners for the subscribe object

    protected function addSubscribeEventListeners():void {
        subscribeObject.addEventListener(SubscribeEvent.CONNECT, onSubscribe);
        subscribeObject.addEventListener(SubscribeEvent.DATA, onSubscribe);
        subscribeObject.addEventListener(SubscribeEvent.DISCONNECT, onSubscribe);
        subscribeObject.addEventListener(SubscribeEvent.ERROR, onSubscribe);
        subscribeObject.addEventListener(SubscribeEvent.WARNING, onSubscribe);
        /*subscribeObject.addEventListener(SubscribeEvent.PRESENCE, onSubscribe);*/

        subscribeObject.addEventListener(NetMonEvent.SUB_NET_UP, onNetStatus);
        subscribeObject.addEventListener(NetMonEvent.SUB_NET_DOWN, onNetStatus);
    }


    // this is what runs when we resume from sleep

    private function onEnvironmentReconnect(e:EnvironmentEvent):void {
        if (subscribeObject) {
            dispatchEvent(new PnEvent(PnEvent.RESUME_FROM_SLEEP));
            instance.subscribeObject.onError(new OperationEvent(OperationEvent.TIMEOUT));

        }
    }
    /**
	 * 
	 * 
	private function onEnvironmentShutdown(e:EnvironmentEvent):void {
        shutdown(Errors.NETWORK_LOST);
    }*/

    // currently, there is the notion of "shutdown". Remove this state. There only needs to be:

    // Connected
    //      -   Subscribed
    //      -   Unsubscribed
    // Not Connected


    // remove "shutdown" we dont need this.

	/**
	 * 
	 * 
    private function shutdown(reason:String = ''):void {
        var channels:String = 'no channels';
        var lastToken:String = null;
        if (subscribeObject) {
            if (subscribeObject.channels) {
                channels = subscribeObject.channels.join(',');
            }
            lastToken = subscribeObject.lastReceivedTimetoken;
        }

        nonSubConnection.close();
        environment.stop();
        //_initialized = false;	// gut out unused code

        Log.log('Shutdown', Log.WARNING);
        dispatchEvent(new EnvironmentEvent(EnvironmentEvent.SHUTDOWN, null, [0, reason, channels, lastToken]));
    }
*/

    // this can probably be refactored up.

	/**
	 *  gut out unused code
	 * 
    private function startEnvironment():void {
        _initialized = true;
        environment.start();
        dispatchEvent(new PnEvent(PnEvent.INIT, "Init Completed"));
    }

    private function onInitError(event:OperationEvent):void {
        dispatchEvent(new PnEvent(PnEvent.INIT_ERROR, Errors.INIT_OPERATION_ERROR));
    }*/

    /*---------------SUBSCRIBE---------------*/
    public static function subscribe(channel:String, token:String = null):void {
        Pn.__instance.subscribeObject.subscribe(channel, token);
    }

    private function onSubscribe(e:SubscribeEvent):void {
        var subscribe:Subscribe = e.target as Subscribe;
        var status:String;

        trace("PN.onSubscribe: " + e);

        switch (e.type) {
            case SubscribeEvent.CONNECT:
                status = OperationStatus.CONNECT;
                break;

            case SubscribeEvent.DATA:
                status = OperationStatus.DATA;
                break;

            case SubscribeEvent.DISCONNECT:
                status = OperationStatus.DISCONNECT;
                break;

            // we do not need a presence event
			/**
			 * 
			 * 
            case SubscribeEvent.PRESENCE:
                status = OperationStatus.DISCONNECT;
                dispatchEvent(new PnEvent(PnEvent.PRESENCE, e.data, e.data.channel));
                return;
                break;*/

            case SubscribeEvent.WARNING:
                status = OperationStatus.WARNING;
                break;

            default:
                status = OperationStatus.ERROR;
        }
        dispatchEvent(new PnEvent(PnEvent.SUBSCRIBE, e.data, e.data.channel, status));
    }

    // these are handlers for subscribeConnection network events
    private function onNetStatus(e:NetMonEvent):void {
        dispatchEvent(e);
    }


    /*---------------UNSUBSCRIBE---------------*/

    public static function forceTimeout():void {
        instance.subscribeObject.retryToConnect(new NetMonEvent("foo"));
    }

    public static function unsubscribe(channel:String):void {
        instance.unsubscribe(channel);
    }

    public function unsubscribe(channel:String):void {
        subscribeObject.unsubscribe(channel);
    }

    public static function unsubscribeAll():void {
        instance.unsubscribeAll();
    }

    public function unsubscribeAll():void {
        if (subscribeObject) subscribeObject.unsubscribeAll();
    }

    /*---------------DETAILED HISTORY---------------*/
    public function detailedHistory(args:Object):void {
        var channel:String = args.channel;
        var sub_key:String = args['sub-key'];
        if (channel == null ||
                channel.length == 0 ||
                sub_key == null ||
                sub_key.length == 0) {
            dispatchEvent(new PnEvent(PnEvent.DETAILED_HISTORY, [ -1, 'Channel and subKey are missing'], channel, OperationStatus.ERROR));
            return;
        }

        var history:HistoryOperation = new HistoryOperation(origin);
        history.cipherKey = cipherKey;
        history.setURL(null, args);
        history.addEventListener(OperationEvent.RESULT, onHistoryResult);
        history.addEventListener(OperationEvent.FAULT, onHistoryFault);

        Pn.nonSubConnection.executeGet(history);
    }

    private function onHistoryResult(e:OperationEvent):void {
        var pnEvent:PnEvent = new PnEvent(PnEvent.DETAILED_HISTORY, e.data, e.target.channel, OperationStatus.DATA);
        pnEvent.operation = e.target as Operation;
        dispatchEvent(pnEvent);
    }

    private function onHistoryFault(e:OperationEvent):void {
        var pnEvent:PnEvent = new PnEvent(PnEvent.DETAILED_HISTORY, e.data, e.target.channel, OperationStatus.ERROR);
        pnEvent.operation = e.target as Operation;
        dispatchEvent(pnEvent);
    }


    /*---------------PUBLISH---------------*/

    // TODO: Install URLLoader connectError handler for auto-reconnect

    public static function publish(args:Object):void {
        instance.publish(args);
    }

    public function publish(args:Object):void {
        var operation:Operation = createPublishOperation(args)
        Pn.nonSubConnection.executeGet(operation);
    }

    private function onPublishFault(e:OperationEvent):void {
        //trace('onPublishFault : ' + e.target.url);
        var pnEvent:PnEvent = new PnEvent(PnEvent.PUBLISH, e.data, e.target.channel, OperationStatus.ERROR);
        pnEvent.operation = e.target as Operation;
        dispatchEvent(pnEvent);
    }

    private function onPublishResult(e:OperationEvent):void {
        var pnEvent:PnEvent = new PnEvent(PnEvent.PUBLISH, e.data, e.target.channel, OperationStatus.DATA);
        pnEvent.operation = e.target as Operation;
        dispatchEvent(pnEvent);
    }

    private function createPublishOperation(args:Object = null):Operation {
        var publish:PublishOperation = new PublishOperation(origin);
        publish.cipherKey = cipherKey;
        publish.secretKey = secretKey;
        publish.publishKey = _publishKey;
        publish.subscribeKey = _subscribeKey;
        publish.setURL(null, args);
        publish.addEventListener(OperationEvent.RESULT, onPublishResult);
        publish.addEventListener(OperationEvent.FAULT, onPublishFault);
        return publish;
    }


    /*---------------TIME---------------*/
    public static function time():void {
        instance.time();
    }

    public function time():void {
        //throwInit();

        var time:TimeOperation = new TimeOperation(origin);
        time.addEventListener(OperationEvent.RESULT, onTimeResult);
        time.addEventListener(OperationEvent.FAULT, onTimeFault);
        time.setURL();

        Pn.nonSubConnection.executeGet(time);
    }

    private function onTimeFault(e:OperationEvent):void {
		if (e.data.hasOwnProperty("reTry")) {
			flash.utils.setTimeout(time, 1000);
		} else {
	        var pnEvent:PnEvent = new PnEvent(PnEvent.TIME, e.data, null, OperationStatus.ERROR);
	        dispatchEvent(pnEvent);
		}
    }

    private function onTimeResult(e:OperationEvent):void {
        var pnEvent:PnEvent = new PnEvent(PnEvent.TIME, e.data, null, OperationStatus.DATA);
        dispatchEvent(pnEvent);
    }


    public static function getSubscribeChannels():Array {
        if (instance.subscribeObject) {
            return instance.subscribeObject.channels.channelList;
        } else {
            return null;
        }
    }

    public function get sessionUUID():String {
        return _sessionUUID;
    }

    public function get publishKey():String {
        return _publishKey;
    }

    public function get subscribeKey():String {
        return _subscribeKey;
    }
	/**
	 *  gut out unused code
	 * 
    public function get initialized():Boolean {
        return _initialized;
    }*/

    public function get origin():String {
        return _origin;
    }

    public function set origin(value:String):void {
        _origin = value;
        if (value == null || value.length == 0) throw('Origin value must be defined');
        if (_ssl) {
            _origin = "https://" + value;
        }
        else {
            _origin = "http://" + value;
        }
        if (subscribeObject) {
            subscribeObject.origin = _origin;
        }
        environment.origin = _origin;
    }

    public function get ssl():Boolean {
        return _ssl;
    }


}
}
