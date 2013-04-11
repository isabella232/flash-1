# YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
http://www.pubnub.com/account

## PubNub 3.4.1 Real-time Cloud Push API - AS3, Flex, and Air

PubNub is a blazingly fast cloud-hosted messaging service for building
real-time web and mobile apps. Hundreds of apps and thousands of developers
rely on PubNub for delivering human-perceptive real-time
experiences that scale to millions of users worldwide. PubNub delivers
the infrastructure needed to build amazing MMO games, social apps,
business collaborative solutions, and more.

### In a nutshell

* Import PubNub
```
    import com.pubnub.*;
```

* Bind some event listeners to the singleton
```
    Pn.instance.addEventListener(PnEvent.INIT, onInit);
    Pn.instance.addEventListener(PnEvent.SUBSCRIBE, onSubscribe);
    Pn.instance.addEventListener(PnEvent.PRESENCE, onPresence);
    Pn.instance.addEventListener(PnEvent.DETAILED_HISTORY, onDetailedHistory);
    Pn.instance.addEventListener(PnEvent.PUBLISH, onPublish);
    Pn.instance.addEventListener(PnEvent.TIME, onPnTime);
    Pn.instance.addEventListener(PnEvent.RESUME_FROM_SLEEP, onPnResumeFromSleep);

    Pn.instance.addEventListener(SystemMonitorEvent.SUB_NET_UP, onPnConnected);
    Pn.instance.addEventListener(SystemMonitorEvent.SUB_NET_DOWN, onPnDisconnected);
```

* Create an init object
```
    var config:Object = {
        origin: "pubsub.pubnub.com",
        publish_key: "demo",
        sub_key: "demo",
        secret_key: "demo",
        cipher_key: "",
        ssl: true
    }
```

* Initialize the singleton
```
    Pn.init(config);
```

* Pub, Sub, and More Fun!
```
    // Time
    Pn.time();
    
    // Subscribe
    Pn.subscribe("my_channel");
    Pn.subscribe("another_channel,and_another_channel,another_channel-pnpres");
    
    // Unsubscribe
    Pn.unsubscribe("my_channel");
    
    // Publish
    Pn.publish({channel: "my_channel", message: "hiya"});

    // History
    var args:Object = { };
    args.channel = "my_channel";
    args['sub-key'] = "demo";
    Pn.instance.detailedHistory(args);
```

## Full Blown Example!
[3.4.1/src/PubNubFlexExample.mxml](3.4.1/src/PubNubFlexExample.mxml) a simple Flex demo application which 
exposes all PubNub Flash Client functionality.
