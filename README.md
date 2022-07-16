# Scripts to install my config of Arch Linux DWM
Note: this is a project in test phase. Therefore, many features may not yet work.

## Scripts
This repo contains 2 scripts: base.sh and dwm.sh.
The idea is to first follow perform some premilinary steps until you have chrooted into the install. After that, run base.sh, reboot, login as the non-root user and run dwm.sh.

## Preliminary steps
Before running the scripts, you should follow the following steps.
- Boot from a usb stick with the Arch Linux iso on it.
- Set your console keyboard layout. This only applies to non-US layouts. For Belgian layout type: `loadkeys be-latin1`
- Check your internet connection with e.g. `ping archlinux.org`. You can quit out of that with Ctrl+c. Use ethernet if possible to avoid problems.
- Run `timedatectl set-ntp true` (not sure if really needed though)
- Create partitions, format and mount them. There are many ways of doing this (MBR or GPT, swap or no swap, separate home partition or not, ...). For the rest of the process, we assume that you mount the root filesystem to /mnt.
Some usefull guidelines for formatting the partitions:

   -Swap
```
mkswap /dev/sdxn
swapon /dev/sdxn
```

   - Boot partition for uefi
```
mkfs.fat -F32 /dev/sdxm
```

   - Root partition
```
mkfs.ext4 /dev/sdxp
```
   - Root partition removable
```
mkfs.ext4 -0 "^has_journal" /dev/sdxp
```

If you later specify that you are installing on a removable device in the base.sh script, journalling will be configured to use RAM instead of the drive itself. 

- Run the following commands to install linux, create the fstab file and change root into the installed system:
```
pacstrap /mnt base base-devel linux linux-firmware vim git
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash
```
## Git clone this repo
Once chrooted into the install. Run the following commands.
```
git clone https://github.com/PieterCoremans/arch-install-scripts.git
cd arch-install-scripts
```

## Base.sh
If necessary, make base.sh executable by typing:
```
chmod +x base.sh
```

Than run the script by typing:
```
./base.sh
```
Follow the instruction when prompted.

## Dwm.sh
When logged in as the non-root user, go again into the arch-install-scripts directory and if necessary, make dwm.sh executable by typing:
```
sudo chmod +x dwm.sh
```

Than run the script by typing:
```
./dwm.sh
```
Follow the instruction when prompted.

## Notes

### Keyboard layout
These script have been written for a French Azerty keyboard layout with the option to switch to a Belgian Azerty layout. If you do not have either of these layouts, you will need to change some settings within these scripts, the xinitrc file  as well as in the dwm config.h file, most notably regarding the tags hotkeys.

### VirtualBox full screen
If you install on VirtualBox, perform the following steps after install and login to get full screen:
```
sudo pacman -S virtualbox-guest-utils
systemctl enable vboxservice.service
```
After rebooting, select View -> Auto-resize Guest Display

## Caveat
I have written these script for personal use. I cannot be held responsible for any unwanted results that follow from you running these scripts on any of your machines. I highly encourage you to have some knowledge of intalling Arch linux and to read through these scripts before running them on your machine.

## Installation on USB stick: disable KMS
If installing on a removable drive, and after rebooting after running base.sh, you get stuck during boot (i.e. you do not get to the point where you can login) an additional step might be neccesary.
Boot back into the Arch iso, mount the intall boot partition to /mnt and arch-chroot into the install like you did before. Then:
```
vim /etc/default/grub
```
and add `nomodeset` after `quiet` within the quotation mark. After that, regeneration the grub configuration file:
```
grub-mkconfig -o /boot/grub/grub.cfg
```
