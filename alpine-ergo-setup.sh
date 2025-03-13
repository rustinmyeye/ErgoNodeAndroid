#!/bin/bash

if [ -f "./run-alpine.sh" ]; then
    ./run-alpine.sh
    exit
fi

curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/refs/heads/master/init-alpine.sh -o init-alpine.sh
chmod +x init-alpine.sh
curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/refs/heads/master/run-alpine.sh -o run-alpine.sh
chmod +x run-alpine.sh
./init-alpine.sh
clear
echo "
apk add bash curl
sh <(curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/nipopow-ergo-node.sh)
" >> .alpinelinux_container/root/.profile
./run-alpine.sh
