#!/usr/bin/env bash

echo "Hello $(whoami)! Let's start the setup."

# Install Oh My Zsh if not present
if test ! "$(which omz)"; then
    echo "Installing Oh My Zsh ..."
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install powerlevel10k theme - TODO: migrate to brew install
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# Install Homebrew if not present
if test ! "$(which brew)"; then
    echo "Installing Homebrew ..."

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/aznaar/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi 

# Update Homebrew recipes
brew update

# Install all dependencies using brewfile
brew tap homebrew/bundle
brew bundle --file ./Brewfile

# SSH Key generation - TODO: review setup 
#echo "Generating a new SSH key for GitHub"
#ssh-keygen -t ed25519 -C "dimitri.kandassamy@gmail.com" -f ~/.ssh/id_ed25519
#eval "$(ssh-agent -s)"
#touch ~/.ssh/config
#echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_ed25519" | tee ~/.ssh/config
#ssh-add -K ~/.ssh/id_ed25519
#echo "run 'pbcopy < ~/.ssh/id_ed25519.pub' and paste that into GitHub"

# Set macos preferences 
# shellcheck source=.macos
source .macos