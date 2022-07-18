#!/bin/bash

# Copyright Pieter Coremans 2022. Licensed under the EUPL-1.2 or later

# This script installs a base installation of Arch Linux with a non-root user, given the performance of the preliminary steps.

###################
#Preliminary steps#
###################

printf "\e[1;32mHello there!

This script will perform a base install of Arch Linux. 
Before continuing, make sure you performed the preliminary steps as outlined in the README file.
\e[0m"

run_script (){
read -p "Did you run these steps (yes/no)?" ran_prelim

case $ran_prelim in
        yes) echo "Alright, let continue the script!";;
        no) echo "Oh, that we stop you right there. Please run these steps before continuing. This script will now quit." && sleep 2s && exit 1;;
        *) echo "please type yes or no" && run_script;;
esac
}

run_script

######################################
#Set up the variables for this script#
######################################

echo "The timezone will be set to Europe/Brussels. If you want this to be different, please change the script file."
sleep 2s

timezone="/Europe/Brussels"

set_root_password (){
read -sp "Type root password: " password_root; echo -e "\n"
read -sp "Retype root password: " password_root_check; echo -e "\n"
}

set_root_password

while [ $password_root != $password_root_check ];
do
        echo "You did not type the same password twice. Please restart"
        unset password_root password_root_check
        set_root_password
done
unset password_root_check

read -p "Type user name: " name_user

set_user_password (){
read -sp "Type user password: " password_user; echo -e "\n"
read -sp "Retype user password: " password_user_check; echo -e "\n"
}

set_user_password

while [ $password_user != $password_user_check ];
do
        echo "You did not type the same password twice. Please restart"
        unset password_user password_user_check
        set_user_password
done
unset password_user_check

lsblk

boot_install (){
read -p "Do you want to install 1)bios or 2)uefi (type 1 or 2)?" install_choice

case $install_choice in 
        1) echo "bios selected" && read -p "Type install disk (e.g. /dev/sda): " bios_install_disk;;
        2) echo "uefi selected" && read -p "Type uefi mount point (e.g. /boot/efi): " uefi_mount;;
        *) echo "Please type 1 for bios or 2 for uefi" && boot_install;;
esac
}

boot_install

removable_install (){
read -p "Do you want to install on a removable usb drive (yes/no)?" remove_choice

case $remove_choice in
        yes) mv /etc/mkinitcpio.conf /etc/mkinitcpio.conf.orig && cat /etc/mkinitcpio.conf.orig | grep -v "^#" | sed s/"autodetect"/"block keyboard autodetect"/ | sed s/"block filesystems keyboard"/"filesystems"/ > /etc/mkinitcpio.conf && mkinitcpio -p linux;;
        no) echo "no removable drive";;
        *) echo "Please type yes or no" && removable_install;;
esac
}

removable_install

if [ $install_choice = 1 ] && [ $remove_choice = "yes" ]; then
        install_type="bios_remove"
elif [ $install_choice = 1 ] && [ $remove_choice = "no" ]; then
        install_type="bios_noremove"
elif [ $install_choice = 2 ] && [ $remove_choice = "yes" ]; then
        install_type="uefi_remove"
else 
        install_type="uefi_noremove"
fi

#specific packages in the pacman command
packages=(networkmanager grub cups alsa-utils openssh rsync network-manager-applet reflector linux-headers) 
#other packages can be added to packages variable if needed "efibootmgr avahi xdg-user-dirs xdg-utils bluez bluez-utils ..."

#video="intel" #change to amd if amd gpu, or nvidia for nvidia gpu

graphics_install (){
        read -p "Do you have an/a 1)intel, 2)amd or 3)nvidia gpu or 4)Don't know (type 1, 2, 3 or 4)?" graphics

case $graphics in 
        1) video="intel" && echo "intel selected";;
        2) video="amd" && echo "amd selected";;
        3) video="nvidia" && echo "nvidia selected";;
        4) video="dontknow" && echo "Don't know selected";;
        *) echo "Please type 1, 2, 3 or 4" && graphics_install;;
esac
}

graphics_install

#systemctl commands
sys_stuff=(NetworkManager)
#other sys_stuff can be added to sys_stuff variable if needed "bluetooth cups.service sshd avahi-daemon tlp ..."

##############
#INSTALLATION#
##############

#General
printf "\e[1;32mSetting locale settings, hostname and root password.
\e[0m"
sleep 2s

ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
sed -i '178s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=be-latin1" >> /etc/vconsole.conf
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.0.1 arch.localdomain arch" >> /etc/hosts
echo root:$password_root | chpasswd

#Pacman packages
printf "\e[1;32mInstalling pacman packages.
\e[0m"
sleep 2s

pacman -S --noconfirm ${packages[@]}

#Video drivers
printf "\e[1;32mInstalling video drivers.
\e[0m"
sleep 2s

case $video in
        intel) pacman -S --noconfirm xf86-video-intel;;
        amd) pacman -S --noconfirm xf86-video-amdgpu;;
        nvidia) pacman -S --noconfirm nvidia nvidia-utils nvidia-settings;;
        dontknow) pacman -S --noconfirm xf86-video-intel xf86-video-amdgpu xf86-video-ati xf86-video-vesa xf86-video-nouveau xf86-video-fbdev;;
        *) echo "no valid variable selected";;
esac

#GRUB
printf "\e[1;32mInstalling GRUB.
\e[0m"
sleep 2s

case $install_type in
        bios_noremove) grub-install $bios_install_disk;;
        uefi_noremove) pacman -S --noconfirm efibootmgr && grub-install --target=x86_64-efi --efi-directory=$uefi_mount --bootloader-id=GRUB;; 
        bios_remove) grub-install $bios_install_disk --removable --recheck;;
        uefi_remove) pacman -S --noconfirm efibootmgr && grub-install --target=x86_64-efi --efi-directory=$uefi_mount --bootloader-id=GRUB --removable --recheck;; 
        *) echo "no variable selected";;
esac

grub-mkconfig -o /boot/grub/grub.cfg

#Systemd
printf "\e[1;32mEnabling systemctl configuration.
\e[0m"
sleep 2s

for x in ${sys_stuff[@]}
do
        systemctl enable $x
done

#User
printf "\e[1;32mSetting user settings.
\e[0m"
sleep 2s

#alternative user management
useradd -mg wheel $name_user
echo ${name_user}:$password_user | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "%wheel ALL=(ALL) NOPASSWD:/home/${name_user}/.local/bin/shutdown_prompt" >> /etc/sudoers
echo "Defaults !tty_tickets" >> /etc/sudoers

#if chosen for removable option, create file for RAM journalling

ram_journal (){
case $remove_choice in
        yes) mkdir /etc/systemd/journald.conf.d && cd /etc/systemd/journald.conf.d && echo "[Journal]" > usbstick.conf && echo "Storage=volatile" >> usbstick.conf && echo "RuntimeMaxUse=30M" >> usbstick.conf ;;
        no) echo "no removable drive -> moving on";;
        *) echo "No valid option was chosen";;
esac
}

ram_journal

#move install scripts to user home folder
cd /
mv arch-install-scripts /home/${name_user}/

printf "\e[1;32mDone! Type exit, then umount -R /mnt and reboot. After rebooting, login as the non-root user and prceed with the installation as described in the README.
\e[0m"

