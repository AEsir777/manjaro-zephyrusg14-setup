#!/bin/bash

# disable sudo
sudo visudo
# add kebing ALL=(ALL:ALL) NOPASSWD: ALL


# start tools
pamac build google-chrome
sudo pacman -S tmux nodejs-lts-iron asusctl supergfxctl rog-control-center vim
pamac build visual-studio-code-bin

# using supergfxctl for GPU passthrough VFIO
# /etc/supergfxd.conf
# {
# "vfio_enable": true,
# "hotplug_type": "Asus"
# }

# sound
sudo pacman -S sof-firmware alsa-ucm-conf mosh
sudo echo "options snd-intel-dspcfg dsp_driver=1" >>  /etc/modprobe.d/soundfix.conf
# audio quality
# turn the sensitive of audio down

# display
xrandr --dpi 150x150
# x11 applications
# -forcedesktopscaling 1.25
# verify which version x11 is running
ps -o user= -C Xorg

# install wayland
sudo yay plasma-workspace 
# fix fcitx5 in wayland
# Set virtual keyboard as fcitx5
# https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
unset QT_IM_MODULE
unset SDL_IM_MODULE
unset GTK_IM_MODULE

# yay
sudo pacman -Syu
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay 
makepkg -si
yay testdisk

# razor
yay -S polychromatic
yay openrazer-driver-dkms
sudo pacman -S linux-headers
sudo modprobe razerkbd
sudo gpasswd -a $USER plugdev
reboot
openrazer-daemon -Fv

# Open razer CLI
# sudo pacman -S python-setuptools
# git clone https://github.com/LoLei/razer-cli.git
# cd razer-cli
# sudo python setup.py install

# Download Discover
# download wechat from Discover
# https://github.com/web1n/wechat-universal-flatpak
# flatpak install com.tencent.WeChat-<arch>.flatpak

# set up vimrc and tmux
ln -sf ~/manjaro-zephyrusg14-setup/.tmux.conf ~/.tmux.conf
ln -sf ~/manjaro-zephyrusg14-setup/.vimrc ~/.vimrc
ln -sf ~/linux-config/coc/coc-settings.json ~/.vim/coc-settings.json
ln -sf ~/linux-config/UltiSnips/* ~/.vim/UltiSnips/

# discord
sudo pacman -S discord
# update version
file $(which discord)
# edit /opt/discord/resources/build_info.json

# chinese keyboard
sudo pacman -S fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-chinese-addons manjaro-asian-input-support-fcitx5
sudo vim /etc/environment
# GTK_IM_MODULE=fcitx
# QT_IM_MODULE=fcitx
# XMODIFIERS=@im=fcitx

# performance
asusctl -c 80
# sudo pacman -S TLP
# systemctl enable tlp.service

# oh my bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
echo ~/.bashrc-* >> ~/.bashrc
rm ~/.bashrc-*

# oh my posh for theme
curl -s https://ohmyposh.dev/install.sh | bash -so
# configure ~/.bashrc
# eval "$(oh-my-posh init bash --config ~/linux-config/catppuccin_mocha.omp.json)"
# override oh my bash theme
exec bash


# fix discord update version
file $(which discord)
cd /opt/discord/Discord
sudo vim resources/build_info.json

# git config
git config --global user.email "lkb2438834817@gmail.com"
git config --global core.editor "vim"

# ssh keys
# download ssh keys from one drive
sudo pacman -S zip unzip
mkdir ~/.ssh
unzip ssh_keys.zip -d ~
mv ~/ssh_keys ~/.ssh
chmod -R 600 ~/.ssh/*

# vim latex bindings
sudo pacman -S zathura zathura-pdf-mupdf
sudo pacman -S extra/texlive-latex extra/texlive-latexextra extra/texlive-plaingeneric texlive-binextra
sudo texconfig rehash
sudo mktexlsr

# latex lsp
yay nodejs npm cmake gdb
wget https://raw.githubusercontent.com/astoff/digestif/master/scripts/digestif -P ~/.local/bin
ln -s ~/linux-config/coc/digestif ~/.local/bin
chmod +x ~/.local/bin/digestif
digestif
# :CocInstall coc-texlab
# C++
# :CocCommand clangd.install
# :CocInstall coc-clangd coc-json
# install https://github.com/astoff/digestif#installation-and-set-up 

# tmux copy
yay xsel

# install wine 
yay Wine
cd ${WINEPREFIX:-~/.wine}/drive_c/windows/Fonts && for i in /usr/share/fonts/**/*.{ttf,otf}; do ln -s "$i"; done
FREETYPE_PROPERTIES="truetype:interpreter-version=35"

# load chinese in wine
# download at https://pc.weixin.qq.com/?lang=en_US
# copy all the fonts from windows to wine
scp k322liu@linux.student.cs.uwaterloo.ca:~/Fonts/* ~/.wine/drive_c/windows/Fonts/
sudo pacman -S winetricks kdialog
winetricks fakeChinese 
# install a bunch of fonts

# docker
yay docker docker-compose

# Nvidia driver
# Need to make sure meta driver are also here
sudo pacman -S linux611-nvidia nvidia-utils lib32-nvidia-utils nvidia-settings
# Nvidia drm
sudo vim /etc/default/grub
# add nvidia-drm.modeset=1
# Early loading
sudo vim /etc/mkinitcpio.conf
# MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
# HOOKS=() line, find the word kms inside the parenthesis and remove it
sudo mkinitcpio -P
sudo update-grub


# set up NTFS
pamac install ntfs-3g


###########################
# allow ssh
sudo pacman -S openssh
sudo systemctl status sshd.service
# set ssh configurations
sudo vim /etc/ssh/sshd_config
# change ListenAddress to private ip, Port, password disable and only allow key
# add ssh key in Authorized key
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
# cat pub key into it

# enable and run
sudo systemctl enable sshd.service 
sudo systemctl enable --now sshd
sshd -t # for debug


##########################
# set up server
# set up swap
sudo mkswap /dev/nvme0n1p4
sudo swapon /dev/nvme0n1p4
sudo bash -c "echo UUID=$(lsblk -no UUID /dev/nvme0n1p4) swap swap defaults 0 0 >> /etc/fstab"
mkinitcpio -P
sudo update-grub
sudo reboot

# change mount point for external drive
yay ntfs-3g
lsblk
sudo blkid /dev/sda2
sudo ntfs-3g /dev/sda2 /mnt/drive


# start docker service
sudo systemctl start docker
# plex docker image
mkdir docker
# plex docker file 
# https://hub.docker.com/r/linuxserver/plex 
# qbit torrent file
# https://hub.docker.com/r/linuxserver/qbittorrent
# sonarr
# https://hub.docker.com/r/linuxserver/sonarr
docker pull linuxserver/sonarr

# hibernation
# https://www.vegard.net/manjaro-enable-hibernate/
# in /etc/deafult/grub add resume=UUID=<> to LINUX_DEFAULT
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo vim /etc/mkinitcpio.conf
# add resume in hooks after udev

# Configure ProntonVPN
sudo pacman -S wireguard-tools
# Download configure files
sudo move ~/Downloads/*.conf /etc/wireguard
# https://protonvpn.com/support/wireguard-manual-linux/ 

# Configure domain name
yay bind
# Host ssh server on Cloudflared
yay cloudflared
# https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/use-cases/ssh/ 

# MiniConda
sudo curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
yay ffmpeg libva-nvidia-driver-git mesa 

# face fusion 3.0
conda init --all
conda create --name facefusion python=3.12
conda activate facefusion

conda install conda-forge::cuda-runtime=12.4.1 conda-forge::cudnn=9.2.1.18
git clone https://github.com/facefusion/facefusion
cd facefusion
python install.py --onnxruntime cuda 
conda deactivate
conda activate facefusion
python facefusion.py run --open-browser

#################################
## Virtualbox
sudo pacman -Syu virtualbox linux611-rt-virtualbox-host-modules
sudo vboxreload
sudo pacman -S linux611-virtualbox-host-modules


# premake4 download from https://sourceforge.net/projects/premake/
cd build/gmake.unix
make
export PATH=$PATH:/home/kebing/premake-4.3/bin/release/
yay premake 
# cmake
yay cmake bear

## CS798
yay imagemagick

## ECE 459
## Rust
## https://wiki.archlinux.org/title/Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup install 1.76.0
yay hyperfine
yay perf
yay valgrind

# automatically detec and gen nvdia driver
sudo mhwd -a pci nonfree 0300
sudo pacman -S cuda
source /etc/profile
export LIBRARY_PATH="/opt/cuda/lib64:$LIBRARY_PATH"

# CS488
yay blender

## Ollama deploy deepseek
curl -fsSL https://ollama.com/install.sh | sh
ollama run deepseek-r1:70b
sudo vim /etc/systemd/system/ollama.service.d
# Add line OLLAMA_MODELS
sudo chown -R ollama:ollama /mnt/driver/Deepseek

sudo docker run -d -p 3000:8080 -e OLLAMA_BASE_URL=http://localhost:11434 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main


systemctl daemon-reload
systemctl restart ollama

##################################
## other applications
yay musescore shotcut

#################################
## Check disk space
du -cha --max-depth=1 ./ | grep -E "M|G"
















