#!/bin/bash

#apt update -y
#apt upgrade -y

#install dependencies

pkg install -y bash bzip2 coreutils curl  findutils gzip ncurses-utils proot tar xz-utils git proot-distro

#download alpine-ergo.sh setup plugin forproot-distro

cd ..
cd usr
cd etc
cd proot-distro
curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/alpine-ergo.sh >> alpine-ergo.sh
clear

#install alpine linux with alpine plugin with proot-distro

proot-distro install alpine
clear

#run alpine linux and start node setup

proot-distro login alpine --  bash <(curl -s https://raw.githubusercontent.com/rustinmyeye/ErgoNodeAndroid/master/alpine-ergo-node.sh)
clear
proot-distro login alpine 


