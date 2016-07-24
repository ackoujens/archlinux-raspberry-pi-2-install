#!/bin/bash
clear

echo '
# ************************************************ #
#      archlinux-raspberry-pi-2-install-script     #
#              written by Jens Ackou               #
#                                                  #
#  install arch linux on a raspberry pi 2 sd card  #
#         tested on a 8Gb micro sd card            #
# ************************************************ #
! Press CTRL + C anytime to abort the shell script !
'

# Display all commands (DEBUG)
# set -x

# Cleanup if nessecary
echo '
Mount Cleanup
-------------'
sudo umount boot
sudo umount root
echo 'DONE
'

echo '
Removing Junk Files
-------------------'
sudo rm -r boot
sudo rm -r root
sudo rm ArchLinuxARM-rpi-2-latest.tar.gz
echo 'DONE
'

# Display mounted volumes
echo '
All Mounted Volumes
-------------------'
lsblk
echo "Enter the location of your sd card (ex: /dev/sdb):"
read uservolume
echo '
'

echo '
Repartitioning SD card
----------------------'
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk $uservolume
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk
  +100M # 100 MB boot parttion
  t # change partition systemid
  c # ... to W95 FAT32 (LBA)
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  p # display partition table
  w # write the partition table
  q # and we're done
EOF
partprobe
echo 'DONE
'

echo '
Creating Filesystem
-------------------'
echo "[boot] ${uservolume}1 => vfat"
sudo mkfs.vfat ${uservolume}1 # create filesystem
mkdir boot # create boot directory
sudo mount ${uservolume}1 boot # mount boot partition

echo "[root] ${uservolume}2 => ext4"
sudo mkfs.ext4 # create filesystem
mkdir root # create root directory
sudo mount ${uservolume}2 root # mount root partition
echo 'DONE
'

echo '
Downloading Arch Linux ARM RPI2
-------------------------------'
wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz # download latest archlinux for rpi2
echo 'DONE
'

echo '
Extracting Downloaded Package
-----------------------------'
echo 'Extracting to root ...'
sudo bsdtar -xpf ArchLinuxARM-rpi-2-latest.tar.gz -C root # extract all contents to root directory
echo 'DONE
'

echo '
Moving Boot Files
-----------------'
# Move command seemed to have problems with moving files between different partitions
# sudo mv root/boot/* boot # move all contents in extracted boot folder to boot directory
echo 'Copying root/boot/* -> boot'
sudo cp --no-preserve=mode,ownership root/boot/* boot
echo 'Removing root/boot/* files'
sudo rm -r root/boot/*
echo 'DONE
'

echo '
Removing Junk Files
-------------------'
sudo rm ArchLinuxARM-rpi-2-latest.tar.gz
echo 'DONE
'

# Disable showing all commands
set +x

echo '
+++ Put the sd card into your Raspberry PI2 and see if everything is working. Enjoy your Arch Distro !'
