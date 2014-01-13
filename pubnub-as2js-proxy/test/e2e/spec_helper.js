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

var secureSetupObject = {
    publish_key       : 'pub-c-05bbe7bf-b4b8-4ce2-8f85-d7b88e8c0e2d',
    subscribe_key     : 'sub-c-d01d9f66-6166-11e3-bb82-02ee2ddab7fe',
    secret_key        : 'sec-c-OWYwMzYwNWYtY2FkZC00NWM2LWJiOTctYjY0MGY2MDg3M2I0'
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