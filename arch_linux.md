# Arch Linux — персональные шпаргалки


## 0. NetworkManager — отключение Wi‑Fi Power Save

```bash
echo -e '[connection]\nwifi.powersave = 2' | sudo tee /etc/NetworkManager/conf.d/99-wifi-powersave-off.conf
```

---

## 1. База и AUR helper (paru)

```bash
sudo pacman -S --needed base-devel git

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

---

## 2. Установка софта (pacman + AUR)

```bash
paru -Syu --needed \
  fish zen-browser-bin telegram-desktop \
  ttf-jetbrains-mono-nerd ttf-jetbrains-mono \
  papirus-icon-theme vimix-cursors mission-center \
  spotify visual-studio-code-bin \
  alhp-keyring alhp-mirrorlist \
  reflector pacman-contrib plocate \
  gst-libav gst-plugins-{good,bad,ugly} gst-plugin-pipewire \
  ffmpegthumbs kdegraphics-thumbnailers qt6-imageformats \
  libva-mesa-driver libva-utils \
  timeshift kitty starship eza \
  ananicy-cpp rate-mirrors amd-ucode nvidia-prime \
  bat arch-update apple-fonts gnome-calculator \
  gnome-clocks
```

### Удаление лишнего (KDE)

```bash
sudo pacman -Rdd discover plasma-welcome plasma-systemmonitor drkonqi
sudo pacman -Rns htop kate konsole
```
---

### Удаление лишнего (GNOME)

```bash
sudo pacman -Rns --noconfirm gnome-calendar gnome-connections gnome-contacts gnome-disk-utility baobab simple-scan gnome-font-viewer gnome-logs gnome-maps gnome-music malcontent gnome-software gnome-system-monitor gnome-tour gnome-weather epiphany snapshot decibels orca yelp gnome-user-docs gnome-characters showtime papers rygel gnome-console gnome-text-editor
sudo pacman -Rdd gnome-color-manager ibus evince
```

### Настройка тачпада GNOME
```bash
paru -Syu libinput-config-git
sudo echo -e "override-compositor=enabled\nscroll-factor=0.5" | sudo tee /etc/libinput.conf > /dev/null
```
#### Quick Lang Switch


### Настройка SDDM

```bash
sudo echo -e "[General]\nNumlock=on" | sudo tee /etc/sddm.conf > /dev/null
```

---

## 3. Fish shell по умолчанию

```bash
chsh -s /usr/bin/fish
```

---

## 4. Важные конфиги (ручная правка)

```bash
code /etc/pacman.conf
code /etc/default/grub
code /etc/mkinitcpio.conf
code /etc/systemd/zram-generator.conf
```

---

## 5. pacman.conf — тюнинг

```ini
[options]
HoldPkg = pacman glibc
Architecture = auto

# UI
Color
ILoveCandy
CheckSpace
VerbosePkgLists
ParallelDownloads = 10

# Безопасность
SigLevel = Required DatabaseOptional
LocalFileSigLevel = Optional
DownloadUser = alpm

[core-x86-64-v3]
Include = /etc/pacman.d/alhp-mirrorlist

[core]
Include = /etc/pacman.d/mirrorlist

[extra-x86-64-v3]
Include = /etc/pacman.d/alhp-mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib-x86-64-v3]
Include = /etc/pacman.d/alhp-mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
```

> ALHP / Chaotic‑AUR → после настройки:
```bash
sudo pacman -Syyuu
```

---

## 6. GRUB — параметры ядра

```ini
GRUB_CMDLINE_LINUX_DEFAULT="nowatchdog nvidia-drm.modeset=1 quiet loglevel=3"
```

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

## 7. ZRAM (systemd‑zram‑generator)

```ini
[zram0]
zram-size = min(ram, 8192)
compression-algorithm = zstd
swap-priority = 100
```

---

## 8. mkinitcpio

```ini
MODULES=(amdgpu nvidia nvidia_modeset nvidia_uvm nvidia_drm)

HOOKS=(systemd autodetect microcode modconf kms sd-vconsole block filesystems fsck)
```

```bash
sudo mkinitcpio -P
```

---

## 9. systemd‑сервисы

```bash
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service

sudo systemctl enable --now \
  fstrim.timer \
  paccache.timer \
  plocate-updatedb.timer \
  ananicy-cpp \
  systemd-resolved \
  dbus-broker.service

sudo systemctl enable --global dbus-broker.service
```

---

## 10. fstab

```bash
code /etc/fstab
```

Рекомендуемо:
```
noatime
```

---

## 11. Пользовательские конфиги

```bash
code ~/.config/kitty
code ~/.config/fish
```

---

## 12. NVMe I/O scheduler

```bash
echo 'ACTION=="add|change", KERNEL=="nvme[0-9]n[1-9]", ATTR{queue/scheduler}="none"' | sudo tee /etc/udev/rules.d/60-ioschedulers.rules
```

---

## 13. Сетевой тюнинг (TCP BBR)

```bash
sudo tee /etc/sysctl.d/99-custom-performance.conf > /dev/null <<'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
vm.vfs_cache_pressure=50
vm.swappiness=150
EOF

sudo sysctl --system
```

---

## 14. Firewall (UFW)

```bash
sudo pacman -S ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo systemctl enable --now ufw
```

---

```bash
echo -e '[main]\ndns=systemd-resolved' | sudo tee /etc/NetworkManager/conf.d/dns.conf
sudo systemctl restart NetworkManager
sudo rm /etc/resolv.conf
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

balooctl6 disable
balooctl6 purge
```