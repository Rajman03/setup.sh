#!/bin/bash

pacman -Syu --noconfirm

sed -i 's/^#pl_PL.UTF-8 UTF-8/pl_PL.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

cat > /etc/locale.conf <<EOF
LANG=pl_PL.UTF-8
LC_TIME=pl_PL.UTF-8
LC_NUMERIC=pl_PL.UTF-8
LC_MONETARY=pl_PL.UTF-8
LC_MEASUREMENT=pl_PL.UTF-8
EOF

echo "KEYMAP=pl" > /etc/vconsole.conf
loadkeys pl

ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
hwclock --systohc

useradd -m -G wheel -s /bin/bash rajman
echo "rajman:haslo123" | chpasswd
echo "root:haslo123" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

cat > /home/rajman/.xinitrc <<EOF
exec Hyprland
EOF

cat > /home/rajman/.bash_profile <<EOF
if [[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]]; then
  exec startx
fi
EOF

cat >> /home/rajman/.bashrc <<EOF
export LANG=pl_PL.UTF-8
export LC_ALL=pl_PL.UTF-8
EOF

cat >> /home/rajman/.xprofile <<EOF
export LANG=pl_PL.UTF-8
export LC_ALL=pl_PL.UTF-8
EOF

chown rajman:rajman /home/rajman/.xinitrc /home/rajman/.bash_profile /home/rajman/.bashrc /home/rajman/.xprofile

pacman -S --noconfirm base-devel git wget hyprland xdg-desktop-portal-hyprland waybar rofi alacritty dolphin thunar xdg-user-dirs network-manager-applet pipewire wireplumber pavucontrol polkit-kde-agent grim slurp wl-clipboard neofetch

sudo -u rajman xdg-user-dirs-update --force

systemctl enable NetworkManager.service
systemctl start NetworkManager.service

mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin rajman --noclear %I \$TERM
EOF

reboot
