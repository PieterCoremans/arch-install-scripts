#!/bin/bash

#This script will install all the .config files and .local files for a functioning dwm install
# Before running this script:
#1) make sure you already ran base.sh with the prerequisites for that script
#2) make this file executable with chmod +x

#Preliminary steps
printf "\e[1;32mSetting clock and mirrorlist.\e[0m"
sleep 2s

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector -c Belgium -a 6 --sort rate --save /etc/pacman.d/mirrorlist

#Install packages
printf "\e[1;32mInstalling pacman packages.\e[0m"
sleep 2s

sudo pacman -S xorg xorg-server xorg-xinit git firefox pcmanfm slock sxiv nitrogen picom ranger neofetch imagemagick htop gvim cmatrix alacritty

#Reset home folders
printf "\e[1;32mDeleting .config and .local folders if they exist.\e[0m"
sleep 2s

cd

if [ -d .config ]; then
        rm -rf .config
fi

if [ -d .local ]; then
        rm -rf .local
fi

#Clone config github directories
printf "\e[1;32mCloning .config folder and making symlinks.\e[0m"
sleep 2s

git clone https://github.com/PieterCoremans/config.git .config
cd .config
chmod +x symlinks
./ symlinks

printf "\e[1;32mInstalling suckless utilities: DWM, st, slstatus and dmenu.\e[0m"
sleep 2s

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
printf "\e[1;32mCloning .local folder.\e[0m"
sleep 2s

git clone https://github.com/PieterCoremans/local.git .local

printf "\e[1;32mDWM and other utilities have now been installed! Reboot to login into your new window manager :)!.\e[0m"
