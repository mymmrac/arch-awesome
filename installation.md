# Installation of Arch Linux

## Connect to network

Wi-Fi method

```shell
$ iwctl

> adapter list
> station <adapter-name> connect "<wifi-name>"
> exit
```

> `<adapter-name>`: wlan0
> `<wifi-name>`: kernel panic

To check if all works:

```shell
$ ip a

$ ping -c 3 8.8.8.8
```

## Enable SSH

```shell
$ passwd

$ systemctl start sshd
```

## Configure time

```shell
$ timedatectl set-ntp true
```

## Update mirror list

```shell
$ reflector --country <country-list> -a 6 --sort rate --save /etc/pacman.d/mirrorlist
$ pacman -Syy
```

> `<country-list>`: Ukraine,USA

## Partition the disk

```shell
$ lsblk

$ gdisk <disk-name>

> o

# EFI Boot
> n
> 
> 
> +512M
> ef00
> c
> Alpha

# Swap
> n
> 
> 
> +<swap-size>G
> 8200
> c
> 2
> Delta

# Root
> n
> 
> 
> 
> 
> c
> 3
> Xi

> p

> w
```

> `<disk-name>`: /dev/sda
> `<swap-size>`: 16

## Make filesystems

```shell
$ mkfs.fat -F32 <disk-name>1

$ mkswap <disk-name>2
$ swapon <disk-name>2

$ mkfs.btrfs <disk-name>3
```

> `<disk-name>`: /dev/sda

## Mount partitions & make sub-volumes

```shell
$ mount <disk-name>3 /mnt

$ btrfs su cr /mnt/@
$ btrfs su cr /mnt/@home
$ btrfs su cr /mnt/@snapshots
$ btrfs su cr /mnt/@log
$ btrfs su cr /mnt/@cache
$ btrfs su cr /mnt/@tmp

$ umount /mnt

$ mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@ <disk-name>3 /mnt

$ mkdir -p /mnt/{boot,home,.snapshots,var/log,var/cache,var/tmp}

$ mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@home <disk-name>3 /mnt/home
$ mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@snapshots <disk-name>3 /mnt/.snapshots
$ mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@log <disk-name>3 /mnt/var/log
$ mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@cache <disk-name>3 /mnt/var/cache
$ mount -o noatime,compress=zstd:3,space_cache=v2,subvol=@tmp <disk-name>3 /mnt/var/tmp

$ mount <disk-name>1 /mnt/boot

$ lsblk
```

> `<disk-name>`: /dev/sda

## Install base packages

```shell
$ pacstrap /mnt base linux linux-firmware intel-ucode neovim
```

## Generate fstab

```shell
$ genfstab -U /mnt >> /mnt/etc/fstab

$ cat /mnt/etc/fstab
```

## Go inside installation

```shell
$ arch-chroot /mnt
```

## Time zone & localization

```shell
$ ln -sf /usr/share/zoneinfo/<time-zone> /etc/localtime
$ hwclock --systohc

$ nvim /etc/locale.gen
```

> `<time-zone>`: Europe/Kyiv

Uncomment `en_US.UTF-8 UTF-8` and `uk_UA.UTF-8 UTF-8`

```shell
$ locale-gen

$ nvim /etc/locale.conf
```

Insert:

```
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
```

## Set hostname

```shell
$ nvim /etc/hostname
```

Insert:

```
mymmrac-pc
```

```shell
$ nvim /etc/hosts
```

Insert:

```
127.0.0.1 localhost
::1       localhost
127.0.1.1 mymmrac-pc.localdomain        mymmrac-pc
```

## Set password

```shell
$ passwd
```

## Install packages

```shell
$ pacman --needed -S \
  grub efibootmgr \
  networkmanager \
  dialog ntp \
  mtools dosfstools \
  reflector \
  snapper rsync \
  xdg-utils xdg-user-dirs \
  pipewire pipewire-pulse pipewire-alsa alsa-utils \
  inetutils pkgconf \
  base-devel linux-headers sudo \
  bash-completion \
  btrfs-progs \
  nvidia
```

network-manager-applet git openssh bluez bluez-utils cups hplip go lua

wpa_supplicant

## Add modules

```shell
$ nvim /etc/mkinitcpio.conf
```

Add and remove following:

```
MODULES=() => MODULES=(btrfs i915 nvidia)
HOOKS=(... fsck) => HOOKS=(...)
```

```shell
$ mkinitcpio -p linux
```

## Grub bootloader

```shell
$ grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
$ grub-mkconfig -o /boot/grub/grub.cfg
```

## Enable services

```shell
$ systemctl enable NetworkManager
$ systemctl enable bluetooth
$ systemctl enable cups
$ systemctl enable sshd
```

## Create user

```shell
$ useradd -mG wheel mymmrac
$ passwd mymmrac

$ EDITOR=nvim visudo
```

Uncomment `%wheel ALL=(ALL) ALL`

## Exit & reboot

```shell
$ exit
$ umount -a
$ reboot
```

## Configure snapper

```shell
$ sudo umount /.snapshots
$ sudo rm -r /.snapshots

$ sudo snapper -c root create-config /
$ sudo btrfs su del /.snapshots

$ sudo mkdir /.snapshots
$ sudo mount -a

$ sudo chmod 750 /.snapshots
$ sudo chown :mymmrac /.snapshots

$ sudo nvim /etc/snapper/configs/root
```

Change following:

```
ALLOW_USERS="" => ALLOW_USERS="mymmrac"
TIMELINE_LIMIT_* => HOURLY="5" DAILY="7" WEEKLY="0" MONTHLY="0" YEARLY="0"
```

```shell
$ sudo snapper -c home create-config /home
$ sudo nvim /etc/snapper/configs/home
```

Change following:

```
ALLOW_USERS="" => ALLOW_USERS="mymmrac"
TIMELINE_LIMIT_* => HOURLY="2" DAILY="7" WEEKLY="2" MONTHLY="0" YEARLY="0"
```

```shell
$ sudo chmod 750 /home/.snapshots
$ sudo chown :mymmrac /home/.snapshots

$ sudo systemctl enable --now snapper-timeline.timer
$ sudo systemctl enable --now snapper-cleanup.timer

$ sudo mkdir /etc/pacman.d/hooks

$ sudo nvim /etc/pacman.d/hooks/50-bootbackup.hook
```

Insert:

```
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
```

## Install yay

```shell
$ git clone https://aur.archlinux.org/yay
$ cd yay
$ makepkg -si
$ cd ..
$ rm -rf yay
```

## Install snap-pac-grub & snapper-gui

```shell
$ yay -S snap-pac-grub snapper-gui
```

## Reboot

```shell
$ sudo reboot
```
