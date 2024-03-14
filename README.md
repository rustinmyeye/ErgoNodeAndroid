THIS DOESNT WORK ANYMORE

Ergo Node for Android
=======

Setup instructions [here](https://github.com/rustinmyeye/ErgoNodeAndroid/blob/master/SETUP_INSTRUCTIONS.md)

An attempt at a one click Ergo node app for Android. I'm not sure what im doing...


![alt text](https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/artwork/ic_launcher_round.png)

Im currently working on
=======

The release available [here](https://github.com/rustinmyeye/ErgoNodeAndroid/releases/tag/v0.1.3) is just a sketchy proof of concept I guess... the app id is still tied to neoterm as well as the inital bootdtrap.

In the version im working on right now, I have refactored all occurrnces of neoterm in the app to ergonode, as well as updated the JNI library with the new name, and created a new bootstrap file system that works with the new name.

I am still working on tje bootsrap file. Im having some problems with Symlinks I think... some things are not happy with the new io.ergonode directory even though I thought I updated them... still figuring it out slowly.

I will start on the "to do" list once this is done, and the app identifies properly as a unique app.

To Do
=======
- fine tune the install script and implement error handling
- include options for light node or full node
- I want to inlude most of the downloads and apps into the initial bootstrap.zip
- remove unsused parts from neotern maybe?
- create menu with hep links, config editor and allow user to create their own API key through menu.
- move bootstrap.zip to this repo

Credits
=======

This is a fork of [NeoTerm](https://github.com/NeoTerrm/NeoTerm)

Im using a bunch of parts from Glasgow's Ergo Node setup scripts. [Mark Glasgow](https://github.com/glasgowm148/ergoscripts)

also - [proot-distro](https://github.com/termux/proot-distro), [Alpine Linux](https://www.alpinelinux.org/), [Ergo Protocol refence client](https://github.com/ergoplatform/ergo/releases)




