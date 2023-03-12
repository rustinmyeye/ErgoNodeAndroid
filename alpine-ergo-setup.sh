#!/bin/bash

#download proot-distro
apt install proot-distro -y

#download alpine-ergo.sh setup plugin for proot-distro
cd ..
cd usr
cd etc
cd proot-distro
curl https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/alpine-ergo.sh >> alpine-ergo.sh

#install alpine linux with alpine-ergo plugin with proot-distro
proot-distro install alpine-ergo

#run alpine linux and start node setup
proot-distro login alpine-ergo --  bash <(curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/alpine-ergo-node.sh)
sleep 1
proot-distro login alpine-ergo 
