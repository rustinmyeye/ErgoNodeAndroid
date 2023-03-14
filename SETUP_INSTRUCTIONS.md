# How to use Ergo Node for Android

## Getting started

This app is intended to be run on aarch64 based Android devices with minimum system requirements of:
* Android OS of version 7.0 or higher
* minimum of 25 GB of internal storage available
* minimum of 3GB ram total 

So far, this has been tested and is working well on a Samsung Galaxy S8+.

## First time setup

Download the latest release .apk file from [here](https://github.com/rustinmyeye/ErgoNodeAndroid/releases), onto the Android device.

Locate the .apk file in your downloads folder, and open it to start the installation. You may need to allow apps from unknown sources in "Settings".

Open the app, click on "start the node", and then click "ok" on the disclaimer about storage requirements.

The app will begin getting things ready to install the node. 

Now allow access to internal storage. Press "allow".

At this point the app will continue downloading all the necessary components to start the node. You will know its running when it says - "The node is now syncing" "Starting the node..."

## Acessing the node panel

To monitor the progress of the node you can visit (in a browser on the device) the Ergo node panel at - https://127.0.0.1:9053/panel. Alternatively, you can monitor progress from another device by replacing 127.0.0.1 with the local or port forwarded public ip of the device running the node.

## Blockchain synchronization

The first sync of the node can take a long time. For example, on a Samsung Galaxy S8+, the sync took ~ 2 days to complete. 

It is helpful to aquire wake lock in the Android app panel for the Ergo Node app. If the sync process gets interrupted or terminated, there is a high likelyhood of corruption, which currently requires the app to be deleted, reinstalled, and resynced to fix :/

## Using the node

Once the node is fully synchronized you can use the node with other apps, such as the [Ergo Mobile Wallet](https://github.com/ergoplatform/ergo-wallet-app) or [ErgoMixer on Android](https://github.com/rustinmyeye/ErgoMixerAndroid) (coming soon...)

In the Ergo Mobile Wallet, simply enter https://127.0.0.1:9053/ in the "node and api connections" section in the settings.

## Shutting the node down

There is no convenient way to shut the node down curently. To shut it down you must enter the Ergo Node app, touch the terminal to bring upt the keyboard, and press "`ctrl + c`"
