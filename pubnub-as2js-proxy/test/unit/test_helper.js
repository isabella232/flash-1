var PUBNUB = {
    init: function () {return PUBNUB;},
    publish: function () {},
    subscribe: function () {}
};

(function () {
    var o = document.createElement('object');
    o.setAttribute('id', 'pubnubFlashObject');
    o.callback = function () {};
    o.created = function () {};
    document.body.appendChild(o);
}());

function expectFailAndSuccessFns(fail, success, errorType) {
    expect(fail).throwException(function (e) {
        expect(e).to.be.a(errorType);
    });

    expect(success).to.not.throwException();
}
