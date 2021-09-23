sudo pacman -Syu --needed \
  base-devel picom glib2 linux-headers \
  git \
  telegram-desktop \
  starship \
  neofetch \
  jdk11-openjdk \
  thunar file-roller thunar-archive-plugin tumbler \
  acpid acpi \
  bat \
  lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings \
  alsa-utils pulseaudio-alsa \
  light \
  noto-fonts \
  rofi \
  compsize \
  networkmanager network-manager-applet \
  unclutter \
  discord \
  playerctl \
  python python-pip \
  libreoffice-still \
  flameshot \
  lxappearance-gtk3 arc-gtk-theme \
  polkit-gnome \
  micro \
  man-db \
  xorg-xkill \
  qalculate-gtk \
  zip unzip \
  lolcat cowsay figlet

# ==================================================================================================================== #

micro .bachrc

alias la='ls -a'
alias pc='sudo pacman -Syu'
eval "$(starship init bash)"

# ==================================================================================================================== #

cd ~/Downloads/
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# ==================================================================================================================== #

yay -Syu \
 jetbrains-toolbox \
 spotify \
 zoom \
 paper-icon-theme-git \
 optimus-manager optimus-manager-qt \
 noisetorch

# ==================================================================================================================== #

timedatectl set-timezone Europe/Kiev
sudo systemctl enable lightdm
sudo chmod +s /usr/bin/light
sudo systemctl enable NetworkManager.service

# ==================================================================================================================== #

# https://www.arcolinuxd.com/awesome/
# https://www.nishantnadkarni.tech/posts/arch_installation/
# https://archlinux.org/mirrorlist/  (WARN Uncomment all servers)

# https://github.com/Askannz/optimus-manager
prime-offload

# Get window class
xprop

# grub-customizer

# ==================================================================================================================== #

sudo micro /etc/X11/xorg.conf.d/30-touchpad.conf

Section "InputClass"
Identifier "touchpad"
Driver "libinput"
  MatchIsTouchpad "on"
  Option "Tapping" "on"
  Option "NaturalScrolling" "off"
  Option "ClickMethod" "clickfinger"
EndSection

# ==================================================================================================================== #

sudo micro /etc/systemd/logind.conf

HandleLidSwitch=suspend
IdleAction=suspend
IdleActionSec=15min

# ==================================================================================================================== #

[Unit]
Description=User suspend lightDM lock screen
Before=sleep.target

[Service]
User=%I
Environment=DISPLAY=:0
Environment=XDG_SEAT_PATH=/org/freedesktop/DisplayManager/Seat0
ExecStart=/usr/bin/dm-tool lock
ExecStartPost=/usr/bin/sleep 1

[Install]
WantedBy=sleep.target

# 1. copy file into /etc/systemd/system/suspend\@.service
# 2. run sudo systemctl enable suspend@<username>

# ==================================================================================================================== #

sudo micro /etc/locale.gen
# uk_UA.UTF-8 UTF-8
# en_US.UTF-8 UTF-8

sudo locale-gen

locale -a

sudo micro /etc/locale.conf
# https://man.archlinux.org/man/locale.7

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

localectl set-x11-keymap --no-convert us,ua pc105+inet "" grp:caps_toggle

sudo reboot

# ==================================================================================================================== #

sudo micro /etc/hosts

127.0.0.1        localhost
::1              localhost
127.0.1.1        mymmrac-pc.localdomain        mymmrac-pc
