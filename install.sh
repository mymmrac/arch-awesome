#!/bin/bash

# Exit on errors
set -e

# Starting
echo -e "Starting...\n"

# Verify internet connection
echo -e "Verifying internet connection...\n"
ping -c 3 -w 8 -q 8.8.8.8
echo

# Enable NTP
echo -e "Enabling NTP..."
timedatectl set-ntp true
echo

# Install charmbracelet/gum
echo -e "Updating pacman database...\n"
pacman -Syy
echo

echo -e "Installing gum...\n"
pacman -S --noconfirm --needed gum
echo

# Update mirror list
REFLECTOR_COUNTRIES=$(gum input --prompt "Countries to search for mirrors: " --placeholder "..." --value "Ukraine,Poland")
echo -e "Mirror list countries: $REFLECTOR_COUNTRIES\n"

gum spin --spinner points --title "Running reflector" -- \
	reflector --country "$REFLECTOR_COUNTRIES" -a 6 --sort rate --save /etc/pacman.d/mirrorlist \
	&& echo -e "Updated mirror list\n"

gum spin --spinner points --title "Updating pacman database" -- \
	pacman -Syy \
	&& echo -e "Updated pacman database\n"

# List disks
CURRENT_DISK_LAYOUT=$(gum style --border normal --padding "0 1" -- "$(lsblk)")
gum join --vertical --align center "Current disk layout" "$CURRENT_DISK_LAYOUT"
echo

# Partition disk
PARTITION_DISK=$(gum input --prompt "Dist to partition: " --placeholder "..." --value "/dev/sda")
echo -e "Partitioning disk: $PARTITION_DISK\n"

if gum confirm --affirmative "Automatic" --negative "Manual" "Partition method"; then 
	echo -e "Automatic partitioning...\n"

	sgdisk --zap-all "$PARTITION_DISK"
	echo
	sgdisk --clear "$PARTITION_DISK"
	echo

	BOOT_PARTITION_SIZE=$(gum input --prompt "Boot partition size: " --placeholder "..." --value "+512M")
	BOOT_PARTITION_NAME=$(gum input --prompt "Boot partition name: " --placeholder "..." --value "Alpha")
	sgdisk -n 0:0:$BOOT_PARTITION_SIZE -t 0:ef00 -c 0:$BOOT_PARTITION_NAME "$PARTITION_DISK"
	echo

	SWAP_PARTITION_SIZE=$(gum input --prompt "Swap partition size: " --placeholder "..." --value "+32G")
	SWAP_PARTITION_NAME=$(gum input --prompt "Swap partition name: " --placeholder "..." --value "Delta")
	sgdisk -n 0:0:$SWAP_PARTITION_SIZE -t 0:8200 -c 0:$SWAP_PARTITION_NAME "$PARTITION_DISK"
	echo

	ROOT_PARTITION_SIZE=$(gum input --prompt "Root partition size: " --placeholder "..." --value "0")
	ROOT_PARTITION_NAME=$(gum input --prompt "Root partition name: " --placeholder "..." --value "Xi")
	sgdisk -n 0:0:$ROOT_PARTITION_SIZE -t 0:8300 -c 0:$ROOT_PARTITION_NAME "$PARTITION_DISK"
	echo
else
	echo -e "Manual partitioning...\n"
	gdisk "$PARTITION_DISK"
	echo
fi

# List disks
CURRENT_DISK_LAYOUT=$(gum style --border normal --padding "0 1" -- "$(lsblk)")
gum join --vertical --align center "Current disk layout" "$CURRENT_DISK_LAYOUT"
echo

# Make boot file system
BOOT_PARTITION=$(gum input --prompt "Boot partition: " --placeholder "..." --value "${PARTITION_DISK}1")
echo -e "Boot partition: $BOOT_PARTITION\n"

mkfs.fat -F32 "$BOOT_PARTITION"
echo

# Make swap
SWAP_PARTITION=$(gum input --prompt "Swap partition: " --placeholder "..." --value "${PARTITION_DISK}2")
echo -e "Swap partition: $SWAP_PARTITION\n"

mkswap "$SWAP_PARTITION"
swapon "$SWAP_PARTITION"
echo

# Make root file system
ROOT_PARTITION=$(gum input --prompt "Root partition: " --placeholder "..." --value "${PARTITION_DISK}3")
echo -e "Root partition: $ROOT_PARTITION\n"

mkfs.btrfs --force "$ROOT_PARTITION"
echo

# Mount file system & create btrfs sub volumes
mount "$ROOT_PARTITION" /mnt

btrfs su cr /mnt/@
btrfs su cr /mnt/@snapshots
btrfs su cr /mnt/@home
btrfs su cr /mnt/@home_snapshots
btrfs su cr /mnt/@log
btrfs su cr /mnt/@cache
btrfs su cr /mnt/@tmp

umount /mnt

mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@ "$ROOT_PARTITION" /mnt

mkdir -p /mnt/{boot,home,.snapshots,var/log,var/cache,var/tmp}

mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@snapshots "$ROOT_PARTITION" /mnt/.snapshots
mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@home "$ROOT_PARTITION" /mnt/home

mkdir -p /mnt/home/.snapshots
mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@home_snapshots "$ROOT_PARTITION" /mnt/home/.snapshots

mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@log "$ROOT_PARTITION" /mnt/var/log
mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@cache "$ROOT_PARTITION" /mnt/var/cache
mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@tmp "$ROOT_PARTITION" /mnt/var/tmp

mount "$BOOT_PARTITION" /mnt/boot

# List disks
CURRENT_DISK_LAYOUT=$(gum style --border normal --padding "0 1" -- "$(lsblk)")
gum join --vertical --align center "Current disk layout" "$CURRENT_DISK_LAYOUT"
echo

read -n 1 -s -r -p "Press any key to continue..."

# Install base packages
pacstrap /mnt base linux linux-firmware intel-ucode

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab
echo

# Set timezone
TIMEZONE=$(gum input --prompt "Timezone: " --placeholder "..." --value "Europe/Kyiv")
echo -e "Timezone: $TIMEZONE"

arch-chroot /mnt ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
arch-chroot /mnt hwclock --systohc

# Set locale
LOCALE_GEN=$(echo -e "en_US.UTF-8 UTF-8\nuk_UA.UTF-8 UTF-8" | \
	gum write --header "Locales to generate (ESC or Ctrl+D to confirm)" --placeholder "..." --height 4 --show-line-numbers --prompt "|")
echo -e "Locale gen:\n$LOCALE_GEN"
echo
echo "$LOCALE_GEN" > /mnt/etc/locale.gen

arch-chroot /mnt locale-gen

LOCALE_CONF=$(echo << EOF
LANG=en_US.UTF-8
LC_ADDRESS=uk_UA.UTF-8
LC_IDENTIFICATION=uk_UA.UTF-8
LC_MONETARY=uk_UA.UTF-8
LC_MEASUREMENT=uk_UA.UTF-8
LC_NAME=uk_UA.UTF-8
LC_NUMERIC=uk_UA.UTF-8
LC_PAPER=uk_UA.UTF-8
LC_TELEPHONE=uk_UA.UTF-8
LC_TIME=uk_UA.UTF-8
EOF | \
	gum write --header "Locales to use (ESC or Ctrl+D to confirm)" --placeholder "..." --height 8 --show-line-numbers --prompt "|")
echo -e "Locale conf:\n$LOCALE_CONF"
echo
echo "$LOCALE_CONF" > /mnt/etc/locale.conf

# Set hostname
HOSTNAME=$(gum input --prompt "Hostname: " --placeholder "..." --value "mymmrac-pc")
echo -e "Hostname: $HOSTNAME"

echo "$HOSTNAME" > /mnt/etc/hostname
echo << EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 $HOSTNAME.localdomain    $HOSTNAME
EOF > /mnt/etc/hosts

# Set root password
arch-chroot /mnt passwd
echo

# Create user
USERNAME=$(gum input --prompt "Username: " --placeholder "..." --value "mymmrac")
echo -e "Username: $USERNAME"
echo

arch-chroot /mnt useradd -mG wheel "$USERNAME"
arch-chroot /mnt passwd "$USERNAME"
arch-chroot /mnt echo "%wheel ALL=(ALL) ALL" | (EDITOR="tee -a" visudo)
echo

# Install packages
arch-chroot /mnt pacman --needed -S \
    grub efibootmgr \
    networkmanager \
    dialog ntp \
    mtools dosfstools \
    reflector \
    snapper rsync \
    xdg-utils xdg-user-dirs \
    inetutils pkgconf \
    base-devel linux-headers sudo \
    bash-completion \
    btrfs-progs grub-btrfs \
	nvidia-open

# Update modules
sed -i "s/^MODULES=()/MODULES=(btrfs i915 nvidia)/" /mnt/etc/mkinitcpio.conf
# TODO: Validate
sed -i "s/^HOOKS=(\([\w ]*\)\bfsck\b\([\w ]*\))/HOOKS=(\1 \2)/" /mnt/etc/mkinitcpio.conf

arch-chroot /mnt mkinitcpio -p linux
echo

# Install GRUB
echo "Install GRUB"
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
echo

# Configure snapper
# TODO

# Boot backup
echo << EOF
[Trigger]
Operation=Upgrade
Operation=Install
Operation=Remove
Type=Path
Target=boot/*

[Action]
Depends=rsync
Description=Backing up /boot...
When=PreTransaction
Exec=/usr/bin/rsync -a --delete /boot /.bootbackup
EOF > /mnt/etc/pacman.d/hooks/50-bootbackup.hook

# Enable services
echo "Enable services"
arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable snapper-timeline.timer
arch-chroot /mnt systemctl enable snapper-cleanup.timer
echo

