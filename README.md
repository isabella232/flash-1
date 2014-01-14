## YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
http://www.pubnub.com/account

### PubNub 3.5 Real-time Cloud Push API - AS3, Flex, and Air

PubNub is a blazingly fast cloud-hosted messaging service for building
real-time web and mobile apps. Hundreds of apps and thousands of developers
rely on PubNub for delivering human-perceptive real-time
experiences that scale to millions of users worldwide. PubNub delivers
the infrastructure needed to build amazing MMO games, social apps,
business collaborative solutions, and more.



## 3.5 is a complete rewrite, and is not compatible with older PubNub Flash/AS3 clients!

We've rewritten this client as a wrapper around our tried-and-true JavaScript client.  Caveat emptor!

### Example App
An example app is available in the demoApp directory.

### Set Up
To set the client up from scratch, perform the following steps:

1. Create a new Flex Project in Flash Builder
2. While setting up the project in the wizard, click "Add SWF Folder", and select the pubnublib/bin directory.
3. In the html-template folder, add pubnub.min.js and pubnub.crypto.min.js. (These files can be found in the PubNub JS Repository located at https://github.com/pubnub/javascript/tree/master/web)
4. In the html-template folder, add pubnub-as2js-proxy.js. (This can be found in the pubnub-as2js-proxy/dist directory.)
5. In the html-template folder, open index.template.html as a text file, and add the following as the last entries within the HEAD tags:

```javascript
    <script src="pubnub.min.js"></script>
    <script src="pubnub-crypto.min.js"></script>
    <script src="pubnub-as2js-proxy.js"></script>
    <script>PUBNUB_AS2JS_PROXY.setFlashObjectId('${application}')</script>
```

6. In your MXML file, add the contents of simplePubNubDemo.txt. Be sure to set the keys appropriately.

 