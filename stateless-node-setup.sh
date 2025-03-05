#!/bin/bash
curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/refs/heads/master/init-alpine.sh >> init-alpine.sh
chmod +x init-alpine.sh
curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/refs/heads/master/run-alpine.sh >> run-alpine.sh
chmod +x run-alpine.sh
./init-alpine.sh
clear
echo "
apk add bash curl
sh <(curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/stateless-ergo-node.sh)
" >> .alpinelinux_container/root/.profile
./run-alpine.sh
