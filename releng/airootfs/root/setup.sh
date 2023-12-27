#!/bin/bash

dialog --msgbox "Welcome to Quantumr8s Arch Linux Installer!" 10 40

# Check for internet connection
if ! ping -q -c 1 -W 1 google.com >/dev/null; then
    # Ask to connect to wifi
    if dialog --yesno "No internet connection found. Do you want to connect to wifi?" 10 40; then
        wifi-menu
    else
        dialog --msgbox "Please connect to the internet and run this script again." 10 40
        exit 1
    fi
fi

# Partition and format the disk
dialog --msgbox "Please partition and format the disk now. When you are done, exit the shell." 10 40
/bin/bash

# Ask for mount points
boot=$(dialog --inputbox "Enter the partition for boot:" 10 40 3>&1 1>&2 2>&3 3>&-)
root=$(dialog --inputbox "Enter the partition for root:" 10 40 3>&1 1>&2 2>&3 3>&-)
home=$(dialog --inputbox "Enter the partition for home:" 10 40 3>&1 1>&2 2>&3 3>&-)
swap=$(dialog --inputbox "Enter the partition for swap:" 10 40 3>&1 1>&2 2>&3 3>&-)

# Mount the filesystems
mkdir -p /mnt/{boot,home}
mount $root /mnt
mount $boot /mnt/boot
mount $home /mnt/home
swapon $swap

# Install bootloader
dialog --infobox "Installing bootloader..." 10 40
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Install the base system
pacstrap -K /mnt base linux linux-firmware

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
arch-chroot /mnt /bin/bash -c '
    # Automatically set the best mirrors
    dialog --infobox "Setting the best mirrors..." 10 40
    pacman -Syy
    pacman -S reflector
    reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

    # Install dialog if not already installed
    if ! command -v dialog &> /dev/null; then
        pacman -S dialog
    fi

    # Set the keyboard layout
    keylayout=$(dialog --inputbox "Enter your keyboard layout (default: us):" 10 40 3>&1 1>&2 2>&3 3>&-)
    loadkeys $keylayout

    # Set the timezone
    timezone=$(dialog --inputbox "Enter your timezone (default: America/New_York):" 10 40 3>&1 1>&2 2>&3 3>&-)
    ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
    hwclock --systohc

    # Set the hostname
    hostname=$(dialog --inputbox "Enter your hostname:" 10 40 3>&1 1>&2 2>&3 3>&-)
    echo $hostname > /etc/hostname

    # Set the root password
    dialog --msgbox "Enter the root password:" 10 40
    passwd

    # Create a new user
    username=$(dialog --inputbox "Enter the name of a new user to create: " 10 40 3>&1 1>&2 2>&3 3>&-)
    useradd -m -G wheel -s /bin/bash $username
    dialog --msgbox "Enter the password for $username:" 10 40
    passwd $username

    # Choose between my versions for desktop or server and install packages
    installtype=$(dialog --inputbox "Do you want to install the desktop or server? [D/s]: " 10 40 3>&1 1>&2 2>&3 3>&-)
    case $installtype in
        [Dd]* ) pacman -S --noconfirm - < /root/releng/packages-desktop.x86_64;;
        [Ss]* ) pacman -S --noconfirm - < /root/releng/packages-server.x86_64;;
        * ) echo "Please answer d or s for desktop or server.";;
    esac
    pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm
    cd ..
    rm -rf yay
    yay -Syu --noconfirm
    yay -S --noconfirm - < /root/releng/packages-aur.x86_64

    # Update grub
    grub-mkconfig -o /boot/grub/grub.cfg

    # initramfs
    mkinitcpio -P

    # Enable services
    systemctl enable NetworkManager
    systemctl enable bluetooth
    systemctl enable sshd
    systemctl enable cups.service
    systemctl enable avahi-daemon.service
    systemctl enable reflector.timer
    sytemctl enable docker.service
'
dialog --msgbox "Unmounting disks..." 10 40
umount -R /mnt

# Setup complete! Please reboot and remove the installation media. press enter to reboot.
dialog --msgbox "Setup complete! Please reboot and remove the installation media." 10 40
sleep 5
reboot
