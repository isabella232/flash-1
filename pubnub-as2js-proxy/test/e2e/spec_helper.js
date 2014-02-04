(function () {
    var o = document.createElement('object');
    o.setAttribute('id', 'pubnubFlashObject');
    o.callback = function () {};
    o.created = function () {};
    o.error = function () {};
    o.instanceError = function () {};
    document.body.appendChild(o);
}());


function addPubNubDiv(pub_key, sub_key) {
    var div = document.createElement('div');

    div.setAttribute('id', 'pubnub');
    div.setAttribute('pub-key', pub_key || 'demo');
    div.setAttribute('sub-key', sub_key || 'demo');

    document.body.appendChild(div);
}

function hashCode() {
    var hash = 0, i, char;
    if (this.length == 0) return hash;
    var l = this.length;
    for (i = 0; i < l; i++) {
        char = this.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash |= 0; // Convert to 32bit integer
    }
    return hash;
}

window.atob || (window.atob = function (string) {
    var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    var result = '';

    var i = 0;
    do {
        var b1 = characters.indexOf(string.charAt(i++));
        var b2 = characters.indexOf(string.charAt(i++));
        var b3 = characters.indexOf(string.charAt(i++));
        var b4 = characters.indexOf(string.charAt(i++));

        var a = ( ( b1 & 0x3F ) << 2 ) | ( ( b2 >> 4 ) & 0x3 );
        var b = ( ( b2 & 0xF  ) << 4 ) | ( ( b3 >> 2 ) & 0xF );
        var c = ( ( b3 & 0x3  ) << 6 ) | ( b4 & 0x3F );

        result += String.fromCharCode(a) + (b ? String.fromCharCode(b) : '') + (c ? String.fromCharCode(c) : '');

    } while (i < string.length);

    return result;
});

function decode64(string) {
    return JSON.parse(atob(string));
}

// NOTICE: only one handler for event supported
function EventEmitter() {
    this.events = {};
}

EventEmitter.prototype.on = function (event_name, fn) {
    this.events[event_name] = fn;
};

EventEmitter.prototype.emit = function (event_name, payload) {
    if (event_name in this.events && typeof this.events[event_name] === 'function') {
        this.events[event_name](payload);
    }
};

var presence_uuid = Date.now();

var secureSetupObject = {
    publish_key       : 'pub-c-05bbe7bf-b4b8-4ce2-8f85-d7b88e8c0e2d',
    subscribe_key     : 'sub-c-d01d9f66-6166-11e3-bb82-02ee2ddab7fe',
    secret_key        : 'sec-c-OWYwMzYwNWYtY2FkZC00NWM2LWJiOTctYjY0MGY2MDg3M2I0'
};

var presenceSetupObject = {
    origin            : 'presence-beta.pubnub.com',
    publish_key       : 'demo',
    subscribe_key     : 'demo',
    uuid              : presence_uuid
};

var setupObject = {
    publish_key       : 'demo',
    subscribe_key     : 'demo',
    secret_key        : null
};

var message_string = 'Hi from Javascript',
    message_jsono = {'message': 'Hi Hi from Javascript'},
    message_jsona = ['message' , 'Hi Hi from javascript'];

window.mocha.setup({ui: 'tdd'});