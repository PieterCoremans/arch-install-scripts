#!/bin/bash

###################
#Preliminary steps#
###################

echo -e \
"Hello there!

This script will perform a base install of Arch Linux. 
Before continuing, make sure you performed the following steps:

1) checked internet acces and ran loadkeys be-latin1 for Belgian layout
2) ran 'timedatectl set-ntp true'
3) partitioned the drives and mounted them
4) ran 'pactrap /mnt base base-devel linux linux-firmware vim git
5) ran 'genfstab -U /mnt >> /mnt/etc/fstab
6) ran 'arch-chroot /mnt /bin/bash'. This will put you in system root

"

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

#passwords of root and user
#password_root="password"
#name_user="pieter"
#password_user="password"

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

#grub-install uefi or bios
#install_type="bios" #change to uefi when needed
#uefi_mount="/boot/efi" #not used if bios
#bios_install_disk="/dev/sdx" #not used if uefi

lsblk

boot_install (){
read -p "Do you want to install 1)bios or 2)uefi (type 1 or 2)?" install_choice

case $install_choice in 
        1) install_type="bios" && echo "bios selected" && read -p "Type install disk (e.g. /dev/sda): " bios_install_disk;;
        2) install_type="uefi" && echo "uefi selected" && read -p "Type uefi mount point (e.g. /boot/efi): " uefi_mount;;
        *) echo "Please type 1 for bios or 2 for uefi" && boot_install;;
esac
}

boot_install

#specific packages in the pacman command
packages=(networkmanager grub cups alsa-utils openssh rsync network-manager-applet reflector linux-headers) 
#other packages can be added to packages variable if needed "efibootmgr avahi xdg-user-dirs xdg-utils bluez bluez-utils ..."

#video="intel" #change to amd if amd gpu, or nvidia for nvidia gpu

graphics_install (){
read -p "Do you have an/a 1)intel, 2)amd or 3)nvidia gpu (type 1, 2 or 3)?" graphics

case $graphics in 
        1) video="intel" && echo "intel selected";;
        2) video="amd" && echo "amd selected";;
        3) video="nvidia" && echo "nvidia selected";;
        *) echo "Please type 1, 2 or 3" && graphics_install;;
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
printf "\e[1;32mSetting locale settings, hostname and root password.\e[0m"
sleep 2s

ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc
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
printf "\e[1;32mInstalling pacman packages.\e[0m"
sleep 2s

pacman -S --noconfirm ${packages[@]}

#Video drivers
printf "\e[1;32mInstalling video drivers.\e[0m"
sleep 2s

case $video in
        intel) pacman -S --noconfirm xf86-video-intel;;
        amd) pacman -S --noconfirm xf86-video-amdgpu;;
        nvidia) pacman -S --noconfirm nvidia nvidia-utils nvidia-settings;;
        *) echo "no valid variable selected";;
esac

#GRUB
printf "\e[1;32mInstalling GRUB.\e[0m"
sleep 2s

case $install_type in
        bios) grub-install $bios_install_disk;;
        uefi) grub-install --target=x86_64-efi --efi-directory=$uefi_mount --bootloader-id=GRUB;; 
        *) echo "no variable selected";;
esac

grub-mkconfig -o /boot/grub/grub.cfg

#Systemd
printf "\e[1;32mEnabling systemctl configuration.\e[0m"
sleep 2s

for x in ${sys_stuff[@]}
do
        systemctl enable $x
done

#User
printf "\e[1;32mSetting user settings.\e[0m"
sleep 2s

#Original user management
#useradd -m pieter
#echo pieter:password | chpasswd
#usermod -aG libvirt pieter
#echo "pieter ALL=(ALL) ALL" >> /etc/sudoers.d/pieter

#alternative user management
useradd -mg wheel $name_user
echo ${name_user}:$password_user | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "Defaults !tty_tickets" >> /etc/sudoers

printf "\e[1;32mDone! Type exit, umount -R /mnt  and reboot.\e[0m"

# After this, you can login as user and proceed with the user specific installation
