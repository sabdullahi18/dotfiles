#!/bin/bash

set -e

USER_NAME="sara"

echo "Starting Arch Linux setup"

echo "Updating system and installing base-devel, git, and stow"
sudo pacman -Syu --noconfirm --needed base-devel git stow

if ! command -v yay &> /dev/null; then
    echo "AUR helper 'yay' not found. Installing..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
else
    echo "'yay' is already installed. Skipping."
fi

echo "Installing Zsh and Zinit"
sudo pacman -S --noconfirm --needed zsh

if [ ! -d "/home/$USER_NAME/.local/share/zinit/zinit.git" ]; then
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
else
    echo "Zinit is already installed. Skipping"
fi

echo "Installing packages..."
sudo pacman -S --noconfirm --needed - < pkglist.txt

echo "Installing packages from the AUR..."
yay -S --noconfirm --neeeded - < pkglist-aur.txt

echo "Symlinking dotfiles using GNU Stow..."
stow . -t "/home/$USER_NAME"

echo "Enabling essential systemd services..."
sudo systemctl enable NetworkManager.service
sudo systemctl enable bluetooth.service

if [[ "$SHELL" != *"/bin/zsh"* ]]; then
    echo "Changing default shell to Zsh for $USER_NAME..."
    sudo chsh -s /bin/zsh $USER_NAME
    echo "Default shell changed. Log out and log back in for change to take effect"
else
    echo "Default shell is already Zsh. Skipping"
fi

echo "All done. Reboot system for changes to take effect"
