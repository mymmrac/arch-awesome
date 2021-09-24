# Post Installation of Arch Linux

## Step 1: Install packages

```shell
$ sudo pacman --needed -S \
  mesa xf86-video-intel nvidia nvidia-utils nvidia-settings \
  xorg-server xorg-xrandr xorg-xkill xorg-xinit xorg-xhost \
  terminus-font libinput unclutter man-db make m4 libvncserver libtool libpulse gettext gcc autoconf automake file fakeroot \
  acpi acpid acpi_call\
  awesome arc-gtk-theme polkit-gnome picom lxappearance-gtk3 \
  lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings \
  maim openssh wget xsel zip unzip gzip which tailscale sed playerctl patch light grep gawk findutils cpio compsize bison binutils \
  neofetch lolcat htop figlet cowsay cmatrix bottom dust jq bat \
  grub-customizer gpicview vlc transmission-gtk telegram-desktop steam remmina qalculate-gtk obs-studio libreoffice-still jupyterlab firefox flameshot discord evince \
  alacritty xterm starship rofi \
  virtualbox virtualbox-host-modules-arch \
  thunar thunar-archive-plugin tumbler file-roller \
  python-pip nodejs-lts-fermium jdk11-openjdk \
  docker docker-compose \
  pipewire-media-session
  
$ yay -S \
  optimus-manager optimus-manager-qt \
  noisetorch zoom spotify jetbrains-toolbox teams minecraft-launcher \
  paper-icon-theme-git
```

## Step 2: Configure touchpad

```shell
$ sudo micro /etc/X11/xorg.conf.d/30-touchpad.conf
# Section "InputClass"
# Identifier "touchpad"nemo
# Driver "libinput"
#   MatchIsTouchpad "on"
#   Option "Tapping" "on"
#   Option "NaturalScrolling" "off"
#   Option "ClickMethod" "clickfinger"
# EndSection
```

## Step 3: Configure locking

```shell
$ sudo micro /etc/systemd/logind.conf
# HandleLidSwitch=suspend
# IdleAction=suspend
# IdleActionSec=15min
```
