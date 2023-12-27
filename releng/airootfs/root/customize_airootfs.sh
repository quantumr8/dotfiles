#!/bin/bash

# Set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Set locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# Set hostname
echo "archlive" > /etc/hostname

# Add a user
useradd -m -G wheel -s /bin/bash archuser
echo "archuser:archuserpassword" | chpasswd

# set the best pacman mirrors
pacman -Sy reflector
reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

# Install installer dependencies
if ! command -v dialog &> /dev/null; then
    pacman -Sy dialog
fi

/root/setup.sh