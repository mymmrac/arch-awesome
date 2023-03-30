# Post Installation of Arch Linux

## Step 1: Install packages

```shell
$ git clone https://aur.archlinux.org/yay
$ cd yay
$ makepkg -si
$ cd ..
$ rm -rf yay
```

```shell
$ sudo micro /etc/pacman.conf
```

Uncomment:

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

```shell
$ sudo pacman -Syyu

$ sudo pacman --needed -S \
  mesa xf86-video-intel nvidia nvidia-utils nvidia-settings \
  xorg-server xorg-xrandr xorg-xkill xorg-xinit xorg-xhost \
  terminus-font ttf-dejavu noto-fonts ttf-liberation ttf-ibm-plex \
  libinput unclutter man-db make m4 libvncserver libtool libpulse gettext gcc autoconf automake file fakeroot \
  acpi acpid acpi_call\
  awesome arc-gtk-theme polkit-gnome picom lxappearance-gtk3 \
  lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings \
  maim openssh wget xsel zip unzip gzip which tailscale sed playerctl patch light grep gawk findutils cpio compsize bison binutils \
  neofetch lolcat htop figlet cowsay cmatrix bottom dust jq bat \
  grub-customizer gpicview vlc transmission-gtk telegram-desktop steam remmina qalculate-gtk obs-studio libreoffice-still jupyterlab firefox flameshot discord evince \
  alacritty xterm starship rofi fish \
  virtualbox virtualbox-host-modules-arch \
  thunar thunar-archive-plugin tumbler file-roller \
  python python-pip nodejs-lts-fermium jdk11-openjdk \
  docker docker-compose \
  pipewire-media-session \
  network-manager-applet \
  git openssh \
  bluez bluez-utils cups hplip \
  go lua
  
$ yay -S \
  mkinitcpio-firmware \
  optimus-manager optimus-manager-qt \
  noisetorch zoom spotify jetbrains-toolbox teams minecraft-launcher \
  paper-icon-theme-git \
  snap-pac-grub snapper-gui
```

## Step 2: Configure touchpad

```shell
$ sudo micro /etc/X11/xorg.conf.d/30-touchpad.conf
```

Insert:

```
Section "InputClass"
    Identifier "touchpad"nemo
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
    Option "NaturalScrolling" "off"
    Option "ClickMethod" "clickfinger"
EndSection
```

## Step 3: Configure locking

```shell
$ sudo micro /etc/systemd/logind.conf
```

Change following:

```
HandleLidSwitch=suspend
IdleAction=suspend
IdleActionSec=15min
```

## Step 4: Copy configs

```shell
$ micro .bashrc
```

Append:

```shell
if [[ $(ps --no-header --pid=$PPID --format=cmd) != "fish" && -z ${BASH_EXECUTION_STRING} ]]
then
  exec fish
fi

alias la='ls -a'
alias ftime='date +"%d.%m.%y    %T" | figlet -tk | lolcat'

eval "$(starship init bash)"
ftime
```

```shell
$ sudo micro /etc/systemd/system/suspend\@.service
```

Insert:

```
[Unit]
Description=User suspend on LightDM lock screen
Before=sleep.target

[Service]
User=%I
Environment=DISPLAY=:0
Environment=XDG_SEAT_PATH=/org/freedesktop/DisplayManager/Seat0
ExecStart=/usr/bin/dm-tool lock
ExecStartPost=/usr/bin/sleep 1

[Install]
WantedBy=sleep.target
```

```shell
$ git clone git@github.com:mymmrac/arch-awesome.git
$ cd arch-awesome/
$ cp -ri configs/* ~/.config/
$ rm -rf arch-awesome/
```

## Step 5: Other configs

```shell
$ sudo chmod +s /usr/bin/light

$ fish_update_completions
$ curl -L https://get.oh-my.fish | fish
```

```shell
$ localectl set-x11-keymap --no-convert us,ua pc105+inet "" grp:caps_toggle
```

## Step 6: Enable services

```shell
$ sudo systemctl enable lightdm
$ sudo systemctl enable suspend@mymmrac
$ sudo systemctl enable bluetooth
$ sudo systemctl enable cups
$ sudo systemctl enable sshd
```

## Step 7: Reboot

```shell
$ reboot
```
