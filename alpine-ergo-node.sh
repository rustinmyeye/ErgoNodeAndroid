#!/bin/bash

#download things
apk add openjdk11 wget python3 curl

#create startup script
cd ..
cd etc
cd profile.d 
curl https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/ergo-startup.sh >> ergo.sh
chmod +x ergo.sh
