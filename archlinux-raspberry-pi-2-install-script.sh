#!/bin/bash

# ************************************************ #
#    archlinux-raspberry-pi-2-install-script.sh    #
#              written by Jens Ackou               #
#                                                  #
#  install arch linux on a raspberry pi 2 sd card  #
#         tested on a 8Gb micro sd card            #
# ************************************************ #

# Display all commands (DEBUG)
# set -x

# Cleanup if nessecary
sudo umount boot
sudo umount root
sudo rmdir boot
sudo rmdir root
sudo rm ArchLinuxARM-rpi-2-latest.tar.gz

# Display mounted volumes
lsblk

# Pick a mounted volume
echo "Choose the location of your sd card (ex: /dev/sdb)"
read uservolume

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
sudo mkfs.vfat /dev/sdb1 # create filesystem
mkdir boot # create boot directory
sudo mount /dev/sdb1 boot # mount boot partition

sudo mkfs.ext4 # create filesystem
mkdir root # create root directory
sudo mount /dev/sdb2 root # mount root partition

wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz # download latest archlinux for rpi2
sudo bsdtar -xpf ArchLinuxARM-rpi-2-latest.tar.gz -C root # extract all contents to root directory

# Move command seemed to have problems with moving files between different partitions
# sudo mv root/boot/* boot # move all contents in extracted boot folder to boot directory
sudo cp --no-preserve=mode,ownership root/boot/* boot
sudo rm -r root/boot/*


# Disable showing all commands
set +x

echo "Put the sd card into your raspberry pi and see if the login menu appears."
