"use strict";

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