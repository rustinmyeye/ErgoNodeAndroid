#!/bin/bash

#apt update -y
#apt upgrade -y

#download git abd install proot-distro

pkg install git
git clone https://github.com/termux/proot-distro
cd proot-distro
./install.shclear

#download alpine-ergo.sh setup plugin for proot-distro
cd ..
cd usr
cd etc
cd proot-distro
curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/alpine-ergo.sh >> alpine-ergo.sh
clear

#install alpine linux with alpine-ergo plugin with proot-distro
proot-distro install alpine-ergo
clear

#run alpine linux and start node setup
proot-distro login alpine-ergo --  bash <(curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/alpine-ergo-node.sh)
clear
proot-distro login alpine-ergo 


