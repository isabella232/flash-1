"use strict";

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
    if (config().async_methods_to_delegate.indexOf(method) < 0) {return;}
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