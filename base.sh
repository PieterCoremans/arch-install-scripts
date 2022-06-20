#!/bin/bash

#Note: before running this script, make sure you have already 
#1) checked internet acces and ran loadkeys be-latin1 for Belgian layout
#2) ran 'timedatectl set-ntp true'
#3) partitioned the drives and mounted them
#4) ran 'pactrap /mnt base base-devel linux linux-firmware vim git
#5) ran 'genfstab -U /mnt >> /mnt/etc/fstab
#6) ran 'arch-root /mnt /bin/bash'. This will put you in system root

######################################
#Set up the variables for this script#
######################################

timezone="/Europe/Brussels"

#passwords of root and user
password_root="password"
name_user="pieter"
password_user="password"

#grub-install uefi or bios
install_type="bios" #change to uefi when needed
uefi_mount="/boot/efi" #not used if bios
bios_install_disk="/dev/sdx" #not used if uefi

#specific packages in the pacman command
packages=(networkmanager grub cups alsa-utils openssh rsync network-manager-applet reflector linux-headers) 
#other packages can be added to packages variable if needed "efibootmgr avahi xdg-user-dirs xdg-utils bluez bluez-utils ..."
video="intel" #change to amd if amd gpu, or nvidia for nvidia gpu

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
