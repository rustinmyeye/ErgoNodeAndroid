Ergo Node for Android
=======

Setup instructions [here](https://github.com/rustinmyeye/ErgoNodeAndroid/blob/master/SETUP_INSTRUCTIONS.md)

An attempt at a one click Ergo node app for Android. I'm not sure what im doing...


![alt text](https://raw.githubusercontent.com/rustinmyeye/ErgoMixerAndroid/main/artwork/c.png)

Im currently working on
=======

The release available [here](https://github.com/rustinmyeye/ErgoNodeAndroid/releases/tag/v0.1.3) is just a sketchy proof of concept I guess... the app id is still tied to neoterm as well as the inital bootdtrap.

In the version im working on right now, I have refactored all occurrnces of neoterm in the app to ergonode, as well as updated the JNI library with the new name, and created a new bootstrap file system that works with the new name.

I am still working on tje bootsrap file. Im having some problems with Symlinks I think... some things are not happy with the new io.ergonode directory even though I thought I updated them... still figuring it out slowly.

I will start on the "to do" list once this is done, and the app identifies properly as a unique app.

To Do
=======

- Im not sure why, but for some reason any node I setup womt sync unless im using a vpn... not sure whats up with that.
- I want to inlude most of the downloads and apps into the initial bootstrap.zip
- figure out android memory management
- reimplement automatic java heap size setup for the node in the install script
- maybe setup swap space in alpine linux? dunno if that helps
- make ui look better and work in all devices
- remove unsused parts from neotern maybe?
- include install scripts in apk maybe
- create menu with hep links, config editor and allow user to create their own API key through menu.
- inclue mixer as an opsional install. It can run alongside the node... and use custom config file maybe
- move bootstrap.zip to this repo

Credits
=======

This is a fork of [NeoTerm](https://github.com/NeoTerrm/NeoTerm)

Im using a bunch of parts from Glasgow's Ergo Node setup scripts. [Mark Glasgow](https://github.com/glasgowm148/ergoscripts)

also - [proot-distro](https://github.com/termux/proot-distro), [Alpine Linux](https://www.alpinelinux.org/), [Ergo Protocol refence client](https://github.com/ergoplatform/ergo/releases)




