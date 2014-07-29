1. Download and extract **Android SDK** https://developer.android.com/sdk/index.html:

   ![](https://github.com/pubnub/flash/raw/master/screenshots/demoAppAirAndroid-setup1.png)

2. Setup **AIR/FLEX SDK**:
    * download and extract FLEX SDK: http://www.adobe.com/devnet/flex/flex-sdk-download.html
    * download AIR SDK for Flex users without new compiler **(not the main download link!)**: http://www.adobe.com/devnet/air/air-sdk-download.html

       ![](https://github.com/pubnub/flash/raw/master/screenshots/demoAppAirAndroid-setup2.png)
    * extract AIR SDK archive over existing content of Flex SDK

3. Clone repository

  ``` sh
  # Checkout repo into a local folder
  $ git clone https://github.com/pubnub/flash.git ./pubnub-flash
  ```

4. Open PubNubDemoAppAir project using IDEA

   ![](https://github.com/pubnub/flash/raw/master/screenshots/demoAppAirAndroid-setup3.png)

5. Add AIR/FLEX SDK to your project

   ![](https://github.com/pubnub/flash/raw/master/screenshots/demoAppAirAndroid-setup4.png)
   ![](https://github.com/pubnub/flash/raw/master/screenshots/demoAppAirAndroid-setup5.png)

6. Start Android virtual device using AVD Manager tool (at the root folder of Android SDK)

   ![](https://github.com/pubnub/flash/raw/master/screenshots/demoAppAirAndroid-setup6.png)

7. Install AIR Runtime to your mobile device using **adt** tool. You can find it at AIR_ANDROID_SDK_HOME/bin/ folder.

  ``` sh
  # change emulator-5554 to your android device name
  $ adt -installRuntime -platform android -device emulator-5554
  ```
  more info http://help.adobe.com/en_US/air/build/WS901d38e593cd1bac1e63e3d128fc240122-7ff6.html

8. Run existing **Air Mobile Demo app** run configuration

   ![](https://github.com/pubnub/flash/raw/master/screenshots/demoAppAirAndroid-setup7.png)