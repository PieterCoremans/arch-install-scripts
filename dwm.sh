#!/bin/bash

#This script will install all the .config files and .local files for a functioning dwm install
# Before running this script:
#1) make sure you already ran base.sh with the prerequisites for that script
#2) make this file executable with chmod +x

#Preliminary steps
echo "Setting clock and mirrorlist"
sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector -c Belgium -a 6 --sort rate --save /etc/pacman.d/mirrorlist

#Install packages
echo "Installing pacman packages"
sudo pacman -S xorg xorg-server xorg-xinit git firefox pcmanfm slock sxiv nitrogen picom ranger neofetch imagemagick htop gvim cmatrix alacritty

#Reset home folders
echo "Deleting .config and .local folders if they exist"
cd

if [ -d .config ]; then
        rm -rf .config
fi

if [ -d .local ]; then
        rm -rf .local
fi

#Clone config github directories
echo "Cloning .config folder"
git clone https://github.com/PieterCoremans/config.git .config

echo "Installing suckless utilities: DWM, st, slstatus and dmenu"
cd .config
mkdir suckless
cd suckless

git clone https://github.com/PieterCoremans/dwm.git
cd dwm
make && sudo make install
cd ..

git clone https://github.com/PieterCoremans/st.git
cd st
make && sudo make install
cd ..

git clone https://github.com/PieterCoremans/slstatus.git
cd slstatus
make && sudo make install
cd ..

git clone https://github.com/PieterCoremans/dmenu.git
cd dmenu
make && sudo make install
cd 

#Clone local github directories
echo "Cloning .local folder"
git clone https://github.com/PieterCoremans/local.git .local

