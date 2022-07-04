#!/bin/bash

###################
#Preliminary steps#
###################

printf "\e[1;32mHello there again!

This script will install all the .config files and .local files for a functioning dwm install
Before running this script:
\e[0m"

echo -e \
"1) make sure you already ran base.sh with the prerequisites for that script
2) read through the script and adapt what's needed
3) make this file executable with chmod +x

"
 
run_script (){
read -p "Are you shure you want to continue (yes/no)?" ran_prelim

case $ran_prelim in
        yes) echo "Alright, let's continue the script!";;
        no) echo "Not now hé? Maybe some other time. This script will now quit." && sleep 2s && exit 1;;
        *) echo "please type yes or no" && run_script;;
esac
}

run_script
sleep 1s

#removable_install (){
#read -p "Do you want to install on a removalbe usb drive?" remove_choice
#
#case $remove_choice in
        #yes) mkdir /etc/systemd/journald.conf.d && cd /etc/systemd/journald.conf.d && echo "[Journal]" > usbstick.conf && echo "Storage=volatile" >> usbstick.conf && echo "RuntimeMaxUse=30M" >> usbstick.conf;;
        #no) echo "no removable drive";;
        #*) echo "Please type yes or no" && removable_install;;
#esac
#}
#
#removable_install

############
#Run script#
############

#Preliminary settings
printf "\e[1;32mSetting clock and mirrorlist.
\e[0m"
sleep 2s

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector -c Belgium -a 6 --sort rate --save /etc/pacman.d/mirrorlist

#Install packages
printf "\e[1;32mInstalling pacman packages.
\e[0m"
sleep 2s

sudo pacman -S xorg-server xorg-xinit xorg-xrandr xorg-xsetroot git firefox pcmanfm slock sxiv nitrogen picom ranger neofetch imagemagick htop gvim cmatrix alacritty go-md2man

#Reset home folders
reset_folders (){
read -p "Are you sure you want to reset .config and .local folders (yes/no)?" folder_reset

case $folder_reset in
        yes) echo "Ok, let's proceed.";;
        no) "Ok, let's quit out of this script." && sleep 2s && exit 1;;
        *) echo "Please type yes or no" && reset_folders;;
esac

}

reset_folders
sleep 1s

printf "\e[1;32mDeleting .config and .local folders if they exist.
\e[0m"
sleep 2s

cd

if [ -d .config ]; then
        rm -rf .config
fi

if [ -d .local ]; then
        rm -rf .local
fi

#Clone config github directories
git_dwnlds (){
read -p "Do you want to git clone Suckless' software with Pieter's adaptations (yes/no)?" git_choice

case $git_choice in
        yes) "Ok, let's continue the git cloning" && sleep 2s;;
        no) "Ok, let's quit out of this script" && sleep 2s && exit 1;;
        *) "Please type yes or no" && git_dwnlds;;
esac
}

git_dwnlds
sleep 1s

printf "\e[1;32mCloning .config folder and making links.
\e[0m"
sleep 2s

cd

git clone https://github.com/PieterCoremans/config.git .config
cd .config
chmod +x links.sh
./links.sh

printf "\e[1;32mInstalling suckless utilities: DWM, st, slstatus and dmenu.
\e[0m"
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

printf "\e[1;32mInstalling Brillo (screen brightness controller).
\e[0m"
sleep 2s

git clone https://gitlab.com/cameronnemo/brillo.git
cd brillo
make && sudo make install.setgid

cd 

#Clone local github directories
printf "\e[1;32mCloning .local folder.
\e[0m"
sleep 2s

git clone https://github.com/PieterCoremans/local.git .local

printf "\e[1;32mDWM and other utilities have now been installed! Reboot to login into your new window manager :)!.
\e[0m"
