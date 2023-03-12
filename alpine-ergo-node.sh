#!/bin/bash

#download things
apk add openjdk11 wget python3

#create startup script
cd ..
cd etc
cd profile.d 
curl https://raw.githubusercontent.com/glasgowm148/ergoscripts/main/sh/super-simple.sh >> ergo.sh
chmod +x ergo.sh

