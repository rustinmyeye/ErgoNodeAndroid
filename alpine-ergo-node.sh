#!/bin/bash

#download things
echo "Downloading stuff... please wait :)"
apk add openjdk11 python3 curl --quiet

#create startup script
cd ..
cd etc
cd profile.d 
curl https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/ergo-startup.sh >> ergo.sh
chmod +x ergo.sh
clear