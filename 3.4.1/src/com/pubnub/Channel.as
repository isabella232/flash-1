/**
 * Created with IntelliJ IDEA.
 * User: geremy
 * Date: 3/31/13
 * Time: 4:59 PM
 * To change this template use File | Settings | File Templates.
 */
package com.pubnub {
import com.pubnub.log.Log;
import com.pubnub.subscribe.SubscribeEvent;

import flash.events.EventDispatcher;

import org.casalib.util.*;


public class Channel extends EventDispatcher {

    public var _retryInterval:int = 0;
    private var _channelList:Array;

    public function Channel() {
        super(null);
        _channelList = [];
    }

    public function validateNewChannelList(operationType:String, channelList:String, reason:Object = null):Array {
        //trace("Sub.validateNewChannelList: " + operationType);

        if (!isChannelListValid(channelList)) {
            //trace("validateNewChannelList: not a valid channellist, so returning a blank array");
            return [];
        }

        var channelsToModify:Array = [];
        var channelListAsArray:Array = channelList.split(',');
        var channelString:String;

        for (var i:int = 0; i < channelListAsArray.length; i++) {
            channelString = StringUtil.removeWhitespace(channelListAsArray[i]);

            if (operationType == "subscribe") {
                if (channelIsInChannelList(channelString)) {
                    dispatchEvent(new SubscribeEvent(SubscribeEvent.WARNING, [ 0, Errors.SUBSCRIBE_ALREADY_SUBSCRIBED, channelString]));
                } else {
                    channelsToModify.push(channelString);
                }
            }
            if (operationType == "unsubscribe") {
                if (channelIsInChannelList(channelString)) {
                    channelsToModify.push(channelString);
                } else {
                    dispatchEvent(new SubscribeEvent(SubscribeEvent.ERROR, [ 0, Errors.SUBSCRIBE_CANT_UNSUB_NON_SUB, channelString]));
                }
            }
        }

        Log.log("validateNewChannelList: activateNewChannelList with " +
                channelsToModify.toString() + " " + operationType);

        return channelsToModify;
    }

    public function activateNewChannelList(newChannelList:Array, operationType:String):String {

        //trace("Sub.activateNewChannelList");

        if (operationType == "unsubscribe") {

            ArrayUtil.removeItems(_channelList, newChannelList);
        }

        else if (operationType == "subscribe") {
            _channelList = _channelList.concat(newChannelList);
        }

        if (channelList.length > 0) {
            //trace("Sub.activateNewChannelList: running executeSubscribeOperation " + this);
            return "resubscribe";

        } else {

            return "shutdown";
        }
    }

    private function isChannelListValid(channel:String):Boolean {
        if (channel == null || channel.length > int.MAX_VALUE) {
            return false;
        }
        return true;
    }

    public function channelIsInChannelList(ch:String):Boolean {
        return (ch != null && _channelList.indexOf(ch) > -1);
    }

    public function get retryInterval():int {
        return _retryInterval;
    }

    public function get channelList():Array {
        return _channelList;
    }

    public function channelsString():String {
        var cString:String = _channelList.join(",");
		return cString;
		
    }

    public function set retryInterval(value:int):void {
        _retryInterval = value;
    }
}
}
