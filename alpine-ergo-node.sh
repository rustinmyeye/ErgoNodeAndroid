#!/bin/bash

#download things
echo "Downloading stuff... please wait :)"
apk add openjdk11 python3 tmux android-tools curl --quiet

#create startup script
cd ..
cd etc
cd profile.d 
#curl https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/ergo-startup.sh >> ergo.sh
curl https://raw.githubusercontent.com/rustinmyeye/ergoscripts/main/sh/install_gui.sh >> ergo.sh
chmod +x ergo.sh
clear