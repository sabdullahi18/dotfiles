#!/bin/bash

set -e

USER_NAME="sara"
COMMENT_CHAR="#"
LINE_NUMBERS=(92 93)
FILE_PATH="/etc/pacman.conf"

echo "-------------------- Starting Arch Linux setup --------------------"

echo "-------------------- Updating system and installing base-devel, git, and stow --------------------" 
sudo pacman -Syu --noconfirm --needed base-devel git stow

if ! command -v yay &> /dev/null; then
    echo "-------------------- AUR helper 'yay' not found. Installing... --------------------"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
else
    echo "-------------------- 'yay' is already installed. Skipping --------------------"
fi

echo "-------------------- Installing Zsh and Zinit --------------------"
sudo pacman -S --noconfirm --needed zsh

if [ ! -d "/home/$USER_NAME/.local/share/zinit/zinit.git" ]; then
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
else
    echo "-------------------- Zinit is already installed. Skipping --------------------"
fi

echo "-------------------- Enabling multilib... --------------------"
for LINE_NUMBER in "${LINE_NUMBERS[@]}"; do
    # sed -n '${LINE_NUMBER}p' prints only that line
    line_content=$(sed -n "${LINE_NUMBER}p" "$FILE_PATH")

    # Check if the line is commented
    if echo "$line_content" | grep -q "^[[:space:]]*${COMMENT_CHAR}"; then

        sed -i "${LINE_NUMBER}s|^[[:space:]]*${COMMENT_CHAR}\s*||" "$FILE_PATH"
        
        echo "Successfully uncommented line $LINE_NUMBER"

    elif [ -n "$line_content" ]; then
        echo "Info: Line $LINE_NUMBER is already uncommented."
    else
        echo "Info: Line $LINE_NUMBER is empty. Nothing to do."
    fi
done

echo "-------------------- Installing packages... --------------------"
sudo pacman -S --noconfirm --needed - < pkglist.txt

echo "-------------------- Installing packages from the AUR... --------------------"
yay -S --noconfirm --needed - < pkglist-aur.txt

echo "-------------------- Removing unnecessary packages... --------------------"
orphans=$(pacman -Qdtq || true)
if [ -n "$orphans" ]; then
    echo "-------------------- Found orphaned packages to remove --------------------"
    echo "$orphans"
    echo "$orphans" | sudo pacman -Rns -
else 
    echo "-------------------- No orphaned packages found --------------------"
fi

echo "-------------------- Symlinking dotfiles using GNU Stow... --------------------"
cd "/home/$USER_NAME/dotfiles"
stow --restow nvim tmux starship fastfetch hypr kitty swaync waybar wofi -t "/home/$USER_NAME/.config"
stow --restow newsboat -t "/home/$USER_NAME"

echo "-------------------- Enabling essential systemd services... --------------------"
sudo systemctl enable NetworkManager.service
sudo systemctl enable bluetooth.service

if [[ "$SHELL" != *"/bin/zsh"* ]]; then
    echo "-------------------- Changing default shell to Zsh for $USER_NAME... --------------------"
    sudo chsh -s /bin/zsh $USER_NAME
    echo "-------------------- Default shell changed. Log out and log back in for change to take effect --------------------"
else
    echo "-------------------- Default shell is already Zsh. Skipping --------------------"
fi

echo "-------------------- Enrolling fingerprint... --------------------"
if ! fprintd-list $(whoami) | grep -q "finger"; then
    echo "-------------------- No fingerprints found for user $(whoami) --------------------"
    sudo sed -i \
        -e '2i\auth       [success=1 default=ignore]  pam_succeed_if.so    service in sudo:su:su-l tty in :unknown' \
        -e '2i\auth sufficient pam_fprintd.so' \
        "/etc/pam.d/system-local-login"
    
    sudo sed -i \
        -e '2i\auth sufficient pam_fprintd.so' \
        "/etc/pam.d/login"
    
    sudo sed -i \
        -e '2i\auth sufficient pam_fprintd.so' \
        "/etc/pam.d/system-auth"
    
    sudo sed -i \
        -e '2i\auth sufficient pam_fprintd.so' \
        "/etc/pam.d/su"
    
    sudo sed -i \
        -e '2i\auth sufficient pam_fprintd.so' \
        "/etc/pam.d/sudo"
    
    fprintd-enroll
else
    echo "-------------------- Fingerprint already found --------------------"
fi

fprintd-verify

echo "-------------------- All done. Reboot system for changes to take effect --------------------"
