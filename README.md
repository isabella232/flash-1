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

## Flash Example App
An example app is available in the demoApp directory.
To set it up from scratch, perform the following steps:

1. Clone repository

``` sh
# Checkout repo into a local folder
$ git clone https://github.com/pubnub/flash.git ./pubnub-flash

# switch to branch 3.5
$ git checkout -b 3.5 origin/3.5
```

2. Set Flash Builder workspace to match root folder of repository

![ScreenShot](/screenshots/demoApp-setup1.png)

3. Import builder projects from folders `pubnublib` and `demoApp`, they are in repository root

![ScreenShot](/screenshots/demoApp-setup2.png)

![ScreenShot](/screenshots/demoApp-setup3.png)

![ScreenShot](/screenshots/demoApp-setup4.png)

4. Set up HTTP to work with the demoApp project. Don't forget to press `Validate Configuration` button

![ScreenShot](/screenshots/demoApp-setup5.png)

5. Create and launch WebApplication configuration for the demoApp project

![ScreenShot](/screenshots/demoApp-setup6.png)

![ScreenShot](/screenshots/demoApp-setup7.png)

6. Browser should load demoApp project and connect to flash_channel automatically. Subscribe button should turn inactive from that point.

![ScreenShot](/screenshots/demoApp-setup8.png)

## Air Example App

1. Clone repository

``` sh
# Checkout repo into a local folder
$ git clone https://github.com/pubnub/flash.git ./pubnub-flash

# switch to branch 3.5
$ git checkout -b 3.5 origin/3.5
```

2. Set Flash Builder workspace to match root folder of repository
3. Import builder project from `demoAppAir` folder, it is in repository root

![ScreenShot](/screenshots/demoAppAir-setup1.png)

4. Create and launch `DesktopApplication` configuration for demoAppAir

![ScreenShot](/screenshots/demoAppAir-setup2.png)

5. Upon launch, app should automatically connect to default channel. Subscribe button should turn inactive.

![ScreenShot](/screenshots/demoAppAir-setup3.png)
