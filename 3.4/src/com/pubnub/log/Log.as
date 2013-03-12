package com.pubnub.log {
import com.pubnub.Pn;
import com.pubnub.PnEvent;
import com.pubnub.environment.EnvironmentEvent;
import com.pubnub.environment.NetMonEvent;
import com.pubnub.operation.Operation;
import com.pubnub.operation.PublishOperation;
import com.pubnub.operation.TimeOperation;

/**
 * ...
 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
 */
public class Log {
    public static const MAX_RECORDS:Number = 288000;

    // LEVELS of log
    public static const NORMAL:String = 'normal';
    public static const DEBUG:String = 'debug';
    public static const WARNING:String = 'warning';
    public static const ERROR:String = 'error';
    public static const FATAL:String = 'fatal';

    private static var __instance:Log;
    private var records:/*LogRecord*/Array = [];
    //private var defaultOp:TimeOperation = TimeOperation new;

    static public function debugMessage(message:String):void {


        try {

            Pn.publish({channel: "airdebug", message: message});
        }
        catch (error:Error) {
            trace("error publishing log: " + error);
        }

    }

    public function Log() {
        if (__instance) throw('Use get instance');
        __instance = this;
    }

    static public function get instance():Log {
        return __instance || new Log();
    }

    static public function log(message:String, level:String = NORMAL, operation:Operation = null):void {

        if (operation && operation.toString() != "[object PublishOperation]") {
            trace("logging: " + operation.toString());
            debugMessage(new Date().toString() + " " + message)
        }

        //trace(new Date() + " " + message);
        var record:LogRecord = new LogRecord(message, level);
        if (instance.records.length > MAX_RECORDS) {
            // flush log
            instance.records.length = 0;
        }
        instance.records.push(record);
    }


    static public function out(type:String = null, level:String = null, reverse:Boolean = true):Array {
        var result:Array = [];
        var records:/*LogRecord*/Array = instance.records;
        var rec:LogRecord;
        var levelResult:Boolean;
        var typeResult:Boolean;
        var len:int = records.length;
        var types:Array = type ? type.split(',') : null;
        for (var i:int = 0; i < len; i++) {
            rec = records[i];
            typeResult = false
            levelResult = false

            typeResult = (types == null) || (types.indexOf(rec.type) > -1);
            levelResult = (level == null) || (rec.level == level);

            if (typeResult && levelResult) {
                result.push(rec.toString(i));
            }
        }
        if (reverse) result.reverse();
        return result;
    }

    static public function clear():void {
        instance.records.length = 0;
    }

    static public function get errors():Array {
        return out(null, ERROR);
    }

}
}

class LogRecord {
    public var level:String;
    public var type:String;
    public var message:String;
    public var date:Date;
    public var index:int = -1;

    public function LogRecord(message:String, type:String, level:String = 'normal', index:int = -1) {
        this.level = level;
        this.index = index;
        this.type = type;
        this.message = message;
        date = new Date();
    }

    public function toString(recordsCount = 0):String {
        //return (index+1) + '.' +  date.toString() + ' [' + level+  '] '+': ' + message;
        return (recordsCount) + '.' + ' [' + level.toUpperCase() + '], \n' + message + ', \ndate: [' + date.toString() + ']';
    }

}