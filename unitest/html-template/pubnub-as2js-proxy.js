(function (root) {
'use strict';

// Source: src/config.js
var config = function () {
    return {
        callback_fields: {
            leave: ['callback', 'error'],
            history: ['callback', 'error'],
            replay: ['callback'],
            publish: ['callback', 'error'],
            unsubscribe: ['callback', 'error'],
            subscribe: ['callback', 'message', 'connect', 'reconnect', 'disconnect', 'error', 'idle', 'presence'],
            here_now: ['callback', 'error', 'data'],
            grant: ['callback', 'error'],
            revoke: ['callback', 'error'],
            audit: ['callback', 'error'],
            where_now: ['callback', 'error']
        },
        methods_with_callback_in_args: [
            'history', 'time', 'publish', 'unsubscribe', 'subscribe', 'here_now', 'grant',
            'audit', 'revoke', 'time', 'where_now'
        ],
        methods_to_delegate: ['history', 'replay', 'subscribe', 'publish', 'unsubscribe', 'here_now', 'grant', 'revoke',
            'audit', 'auth', 'time', 'set_uuid', 'where_now']
    };
};


// Source: src/wrapper.js
/**
 * Wrapper object for PUBNUB instance.
 *
 * @param {string} instanceId
 * @param {HTMLElement} flashObject
 * @param {Object} setup
 * @param {Boolean} [secure]
 * @constructor
 */
function Wrapper(instanceId, flashObject, setup, secure) {
    this.instanceId = instanceId;
    this.flashObject = flashObject;
    setup.error = this.proxyError.bind(this);

    if (setup && secure) {
        this.pubnub = pubnub().secure(setup);
    } else if (setup) {
        this.pubnub = pubnub().init(setup);
    } else {
        this.pubnub = pubnub();
    }
}

/**
 * Applies callback back to flash object
 * @param {String} callbackId
 * @param {Array} payload to apply on as function
 */
Wrapper.prototype.applyCallback = function (callbackId, payload) {
    payload = btoa(JSON.stringify(payload));
    this.flashObject.callback(this.instanceId, callbackId, payload);
};

/**
 * Applies method to PUBNUB instance
 * @param {String} method name
 * @param {Array} args to apply
 */
Wrapper.prototype.applyMethod = function (method, args) {
    if (config().methods_to_delegate.indexOf(method) < 0) {return;}
    var l,
        i;

    for (i = 0, l = args.length; i < l; i++) {
        if (config().methods_with_callback_in_args.indexOf(method) >= 0 &&
            i === (l - 1) &&
            typeof args[i] === 'string') {
            args[i] = this.mockCallback(args[i]);
        } else if (typeof args[i] === 'object') {
            this.mockObjectCallbacks(args[i], config().callback_fields[method])
        }
    }

    this.pubnub[method].apply(this.pubnub, args);
};

Wrapper.prototype.mockCallback = function (callbackId) {
    var _wrapper = this;

    return function () {
        _wrapper.applyCallback(callbackId, objectValues(arguments));
    };
};

/**
 * Wraps each field in object with callback
 *
 * @param {Object} obj
 * @param {Array} fields
 */
Wrapper.prototype.mockObjectCallbacks = function (obj, fields) {
    if (!fields) return;

    for (var property in obj) {
        if (obj.hasOwnProperty(property)) {
            if (fields.indexOf(property) >= 0) {
                obj[property] = this.mockCallback(obj[property]);
            }
        }
    }
};

Wrapper.prototype.proxyError = function (message) {
    this.flashObject.instanceError(this.instanceId, message);
};

// Source: src/pubnubProxy.js
function PubnubProxy() {
    this.delegate(config().methods_to_delegate);
    this.flashObject = null;
    this.flashObjectId = 'pubnubFlashObject';
    this.instances = {};
}

PubnubProxy.prototype.setFlashObjectId = function (flashObjectId) {
    if (!isString(flashObjectId)) {throw new TypeError('flashObjectId argument should be a string')}
    this.flashObjectId = flashObjectId;
};

/**
 * Returns flash object.
 *
 * @returns {HTMLElement}
 */
PubnubProxy.prototype.getFlashObject = function () {
    if (this.flashObject === null) {
        this.flashObject = document.getElementById(this.flashObjectId);
    }

    return this.flashObject;
};

/**
 * Delegate method.
 * Dynamically creates methods that will be available for direct call from ActionScript.
 *
 * @param {Array} methods to delegate
 */
PubnubProxy.prototype.delegate = function (methods) {
    if (!isArray(methods)) {throw new TypeError('delegate method accepts only methods array')}

    var _proxy = this,
        methodsLength = methods.length,
        i;

    for (i = 0; i < methodsLength; i++) {
        this[methods[i]] = function (method) {
            return function (instanceId, args) {
                _proxy.delegatedMethod.call(_proxy, instanceId, method, args);
            };
        }(methods[i])
    }
};

/**
 *
 * @param {String} instanceId
 * @param {String} method
 * @param {Array} args
 */
PubnubProxy.prototype.delegatedMethod = function (instanceId, method, args) {
    this.getInstance(instanceId).applyMethod(method, args);
};

/**
 * Create new wrapper instance with included pubnub object.
 * This method can be called directly from ActionScript.
 *
 * @param {String} instanceId
 * @param {Object} setup
 * @param {Boolean} [secure]
 */
PubnubProxy.prototype.createInstance = function (instanceId, setup, secure) {
    if (!isString(instanceId)) {throw new TypeError('instanceId argument should be a string')}
    if (instanceId in this.instances) {
        this.proxyError('instance with id ' + instanceId + ' already exists');
    }

    var flashObject = this.getFlashObject();
    setup = setup || false;

    this.instances[instanceId] = new Wrapper(instanceId, flashObject, setup, secure);
    flashObject.created(instanceId);
};

PubnubProxy.prototype.getInstance = function (instanceId) {
    if (!(instanceId in this.instances)) {
        this.proxyError('instance with id ' + instanceId + ' is not present')
    }

    return this.instances[instanceId];
};

PubnubProxy.prototype.get_uuid = function (instanceId) {
    return this.getInstance(instanceId).pubnub.get_uuid();
};

PubnubProxy.prototype.uuid = function (instanceId) {
    return this.getInstance(instanceId).pubnub.uuid();
};

PubnubProxy.prototype.proxyError = function (message) {
    this.getFlashObject().error(message);
};

// Source: src/utils.js
function objectValues(obj) {
    var values = [];

    for (var field in obj) {
        if (obj.hasOwnProperty(field)) {
            values.push(obj[field]);
        }
    }

    return values;
}

function isArray(val) {
    if ('isArray' in Array) {
        return Array.isArray(val)
    } else {
        return Object.prototype.toString.call(val) == '[object Array]';
    }
}

function isString (val) {
    return typeof val === 'string';
}

function pubnub () {
    if (typeof PUBNUB === 'undefined') {throw  Error('pubnub.js lib should be included before actionscript proxy lib')}
    return PUBNUB;
}

window.btoa || (window.btoa = function (string) {
    var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    var result = '';

    var i = 0;
    do {
        var a = string.charCodeAt(i++);
        var b = string.charCodeAt(i++);
        var c = string.charCodeAt(i++);

        a = a ? a : 0;
        b = b ? b : 0;
        c = c ? c : 0;

        var b1 = ( a >> 2 ) & 0x3F;
        var b2 = ( ( a & 0x3 ) << 4 ) | ( ( b >> 4 ) & 0xF );
        var b3 = ( ( b & 0xF ) << 2 ) | ( ( c >> 6 ) & 0x3 );
        var b4 = c & 0x3F;

        if (!b) {
            b3 = b4 = 64;
        } else if (!c) {
            b4 = 64;
        }

        result += characters.charAt(b1) + characters.charAt(b2) + characters.charAt(b3) + characters.charAt(b4);

    } while (i < string.length);

    return result;
});

// Source: src/init.js
window['PUBNUB_AS2JS_PROXY'] = new PubnubProxy();

}(this));