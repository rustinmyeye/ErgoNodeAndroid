#!/bin/bash

#download things
echo "Downloading stuff... please wait :)"
#apk --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ add android-tools --quiet
apk add openjdk11 wget curl --quiet

#create startup script
cd ..
cd etc
cd profile.d 
#curl https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/ergo-startup.sh >> ergo.sh
curl https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/alpine-node-install.sh >> ergo.sh
chmod +x ergo.sh
clear
