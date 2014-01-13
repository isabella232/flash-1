var iid = 'uglyInstanceId',
    channel = 'ie_e2e_' + hashCode.call(navigator.userAgent),
    message = 'Hi from Javascript',
    flashObject = document.getElementById('pubnubFlashObject');

describe('#publish', function () {
    it('should publish strings without error', function (done){
        PUBNUB_AS2JS_PROXY.createInstance(iid);

        sinon.stub(flashObject, 'created', function (instanceId) {
            console.log('here');
        });

        sinon.stub(flashObject, 'callback', function (instanceId, callbackId, response) {
        });

//    PUBNUB_AS2JS_PROXY.subscribe(iid, {
//        channel: channel,
//        connected: 'connectedCallbackId',
//        message: 'messageCallbackId'
//    });
    });
});
