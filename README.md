# Don't Use This Right Now, Totally Broken atm
---
# Ergo Node for Android  

Setup instructions [here](https://github.com/rustinmyeye/ErgoNodeAndroid/blob/master/SETUP_INSTRUCTIONS.md)

A one-click Ergo node app for Android. This app is based on **NeoTerm**, and runs automated install scripts to set up and run an Ergo node on Android.

Alternatively, if you'd like to run the setup scripts within **Termux** instead of tbis app, use this one liner:
```
curl -sSL https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/alpine-ergo-setup.sh | sh
```
After initial install, to start the node run:
```
./run-alpine.sh
```

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

## **Notes**

I figured out how to bootstrap via **Nipopow** and **UTXO set snapshot** on **Android**. So far it is only working for me with **RocksDB node 5.1.2**.  

Some important points:

- If you run a **Nipopow node**, there is **no way to see its progress in the panel**. It downloads chunks in the background, so just stick with it, or connect a keyboard Ior use an onscreen keyboard with Ctrl keys) and watch logs.  
- One day I want to figure out how to **add a progress bar for Nipopow chunks** in the panel.  
- It is important to enable wake lock for the app, disable power optimization, and phantom process killing to make this reliable.

Compatibility notes:

- **LevelDB versions** are not working with **aarch64**, when using NiPoPow config even if I try the official aarch64 release.  
- **Termux** and **Neoterm** do not have glibc (it uses musl libc like Alpine Linux), so **RocksDB does not work out of the box**. The workaround is to enable glibc compatibility by installing gcompat in an **Alpine Linux proot** or set up an **Arch Linux proot** to run it.

