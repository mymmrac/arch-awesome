# Installation of Arch Linux

## Step 1: Connect to network

Wi-Fi method

```shell
$ iwctl

$> station wlan0 connect "kernel panic"
$> exit
```

To check if all works:

```shell
$ ip a

$ ping -c 3 8.8.8.8
```

## Step 2: Configure time

```shell
$ timedatectl set-ntp true
```

## Step 3: Update mirror list

```shell
$ reflector -c Ukraine -a 6 --sort rate --save /etc/pacman.d/mirrorlist
$ pacman -Syy
```

## Step 4: Partition the disk

TODO: Name partitions

```shell
$ lsblk

$ gdisk /dev/sda

$> o

# EFI Boot
$> n
$> 
$> 
$> +300M
$> ef00

# Swap
$> n
$> 
$> 
$> +8G
$> 8200

# Root
$> n
$> 
$> 
$> 
$> 

$> w
```

## Step 5: Make filesystems

```shell
$ mkfs.fat -F32 /dev/sda1

$ mkspaw /dev/sda2
$ swapon /dev/sda2

$ mkfs.btrfs /dev/sda3
```

## Step 6: Mount partitions & make sub-volumes

```shell
$ mount /dev/sda3 /mnt

$ btrfs su cr /mnt/@
$ btrfs su cr /mnt/@home
$ btrfs su cr /mnt/@snapshots
$ btrfs su cr /mnt/@var_log

$ umount /mnt

$ mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@ /dev/sda3 /mnt

$ mkdir -p /mnt/{boot,home,.snapshots,var/log}

$ mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@home /dev/sda3 /mnt/home
$ mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@snapshots /dev/sda3 /mnt/.snapshots
$ mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@var_log /dev/sda3 /mnt/var/log

$ mount /dev/sda1 /mnt/boot
```

## Step 7: Install base packages

```shell
$ pacstrap /mnt base linux linux-firmware intel-ucode micro
```

## Step 8: Generate fstab

```shell
$ genfstab -U /mnt >> /mnt/etc/fstab

$ cat /mnt/etc/fstab
```

## Step 9: Go inside installation

```shell
$ arch-chroot /mnt
```

## Step 10: Time zone & localization

```shell
$ ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
$ hwclock -systohc

$ micro /etc/locale.gen
# Uncomment en_US.UTF-8 UTF-8 and uk_UA.UTF-8 UTF-8

$ locale-gen

$ micro /etc/locale.conf
# LANG=en_US.UTF-8
# LC_ADDRESS=uk_UA.UTF-8
# LC_IDENTIFICATION=uk_UA.UTF-8
# LC_MONETARY=uk_UA.UTF-8
# LC_MEASUREMENT=uk_UA.UTF-8
# LC_NAME=uk_UA.UTF-8
# LC_NUMERIC=uk_UA.UTF-8
# LC_PAPER=uk_UA.UTF-8
# LC_TELEPHONE=uk_UA.UTF-8
# LC_TIME=uk_UA.UTF-8
```

## Step 11: Set hostname

```shell
$ micro /etc/hostname
# mymmrac-pc

$ micro /etc/hosts
# 127.0.0.1        localhost
# ::1              localhost
# 127.0.1.1        mymmrac-pc.localdomain        mymmrac-pc
```

## Step 12: Set password

```shell
$ passwd
```

## Step 13: Install packages

TODO: Check what packages are needed

```shell
$ pacman -S \
  grub efibootmgr \
  networkmanager network-manager-applet \
  dialog \
  wda_supplicant \
  mtools dosfstools \
  git \
  reflector \
  snapper rsunc \
  bluez bluez-utils \
  cups hplib \
  xdg-utils xdg-user-dirs \
  pipewire pipewire-pulse pipewire-alsa \
  inetutils \
  base-devel linux-headers \
  bash-completion \
  go
```

## Step 14: Add btrfs module

```shell
$ micro /etc/mkinitcpio.conf
# MODULES=() => MODULES=(btrfs i915 nvidia)
# HOOKS=(... fsck) => HOOKS=(...)

$ mkinitcpio -p linux
```

## Step 15: Grub bootloader

```shell
$ grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
$ grub-mkconfig -o /boot/grub/grub.cfg
```

## Step 16: Enable services

```shell
$ systemctl enable NetworkManager
$ systemctl enable bluetooth
$ systemctl enable cups
```
## Step 17: Create user

```shell
$ adduser -mG wheel mymmrac
$ passwd mymmrac

$ EDITOR=micro visudo
# Uncomment %wheel ALL=(ALL) ALL
```
## Step 18: Exit & reboot

```shell
$ exit
$ umount -a
$ reboot
```

## Step 19: Configure snapper

```shell
$ sudo umount /.snapshots
$ sudo rm -r /.snapshots

$ sudo snapper -c root create-config /
$ sudo btrfs su del /.snapshots

$ sudo mkdir /.snapshots
$ sudo mount -a

$ sudo chmod 750 ./snapshots
$ sudo chown :mymmrac /.snapshots

$ sudo micro /etc/snapper/configs/root
# ALLOW_USERS="" => ALLOW_USERS="mymmrac"
# TIMELINE_LIMIT_* => HOURLY="5" DAILY="7" WEEKLY="0" MONTHLY="0" YEARLY="0"

$ sudo systemctl enable --now snapper-timeline.timer
$ sudo systemctl enable --now snapper-cleanup.timer

$ sudo mkdir /etc/pacman.d/hooks

$ sudo micro /etc/pacman.d/hooks/50-bootbackup.hook
# [Trigger]
# Operation = Upgrade
# Operation = Install
# Operation = Remove
# Type = Path
# Target = boot/*
#
# [Action]
# Depends = rsunc
# Description = Backing up /boot...
# When = PreTransaction
# Exec = /urs/bin/rsync -a --delete /boot /.bootbackup 
```

## Step 20: Install yay

```shell
$ git clone https://aur.archlinux.org/yay
$ cd yay
$ makepkg -si
$ cd ..
$ rm -r yay
```

## Step 21: Install snap-pac-grub & snapper-gui

```shell
$ yay -S snap-pac-grub snapper-gui
```

## Step 22: Install all packages

```shell
$ sudo pacman -S \
  mesa xf86-video-intel nvidia nvidia-utils nvidia-settings \
  xorg awesome
  ....
```

## Step 23: Enable services

```shell
....
```