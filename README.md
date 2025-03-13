# Ergo Node for Android  

Setup instructions [here](https://github.com/rustinmyeye/ErgoNodeAndroid/blob/master/SETUP_INSTRUCTIONS.md)

A one-click Ergo node app for Android. This app is based on **NeoTerm**, and runs automated install scripts to set up and run an Ergo node on Android.

During setup, the script will check the total and available system memory to determine which type of node to run:

- If the device has **more than 5GB of total RAM**, it will run the **NiPoPoW Ergo Node**.
- If the total RAM is **5GB or less**, it will check available memory:
  - If **more than 1.8GB is available**, it will still run the RocksDB **NiPoPoW Ergo Node**.
  - If **less than 1.8GB is available**, it will switch to the **Stateless Ergo Node**, which requires fewer resources.

![alt text](https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/artwork/ic_launcher_round.png)

---

## **Credits**  

This is a fork of [NeoTerm](https://github.com/NeoTerm/NeoTerm)

I’m using a bunch of parts from Glasgow's Ergo Node setup scripts. [Mark Glasgow](https://github.com/glasgowm148/ergoscripts)

Also - [alpine-proot](https://github.com/Yonle/alpine-proot), [Alpine Linux](https://www.alpinelinux.org/), [Ergo Protocol reference client](https://github.com/ergoplatform/ergo/releases)
