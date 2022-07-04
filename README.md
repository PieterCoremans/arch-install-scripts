#Scripts to install my config of Arch Linux DWM
Note: this is a project in test phase. Therefore, many features may not yet work.

##Scripts
This repo contains 2 scripts: base.sh and dwm.sh.
The idea is to first follow perform some premilinary steps until you have chrooted into the install. After that, run base.sh, reboot, login as the non-root user and run dwm.sh.

##Preliminary steps
Before running the scripts, you should follow the following steps.
- Boot from a usb stick with the Arch iso on it.
- Set your console keyboard layout. This only applies to non-US layouts. For Belgian layout type: loadkeys be-latin1
- Check internet (use ethernet if possible to avoid problems)
- Run 'timedatectl set-ntp true' (not sure if really needed though)
- Partition the drives and mount them. There are many ways of doing this (MBR or GPT, swap or no swap, separate home partition or not, ...). If you are installing on a removable usb drive, do not forget to use the -O "^has_journal" flag (after the mkfs command and before the device name). If you later specify that you are installing on a removable device in the base.sh script, journalling will be configured to use RAM instead of the drive itself. For the rest of the process, we assume that you mount the root filesystem to /mnt.
- Run 'pacstrap /mnt base base-devel linux linux-firmware vim git'
- Run 'genfstab -U /mnt >> /mnt/etc/fstab'
- Run 'arch-chroot /mnt /bin/bash'. This will put you in system root.

##Git clone this repo
Once chrooted into the install. Run the following command.
git clone https://github.com/PieterCoremans/arch-install-scripts.git
cd arch-install-scripts

##Base.sh
If necessary, make base.sh executable by typing:
chmod +x base.sh

Than run the script by typing:
./base.sh
Follow the instruction when prompted.

##Dwm.sh
When logged in as the non-root user, go again insto the arch-install-scripts directory and if necessary, make dwm.sh executable by typing:
chmod +x dwm.sh

Than run the script by typing:
./dwm.sh
Follow the instruction when prompted.

##Notes
These script have been written for a French Azerty keyboard layout with the option to switch to a Belgian Azerty layout. If you do not have either of these layouts, you will need to change some settings within these scripts as well as in the dwm config.h file, most notably regarding the tags hotkeys.

##Caveat
I have written these script for personal use. I cannot be held responsible for any unwanted results that follow from you using these scripts on any of your machines. I highly encourage you to have some knowledge of intalling Arch linux and to read through these scripts before running them on your machine.
