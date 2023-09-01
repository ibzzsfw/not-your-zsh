#!/bin/bash

# Define constants
CUSTOM_ZSH="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"
HOME_ZSH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Clone the repository if it does not exist in the directory
function clone_if_not_exists {
    local dir=$1
    local repo_url=$2
    if [ -d "$dir" ]; then
        echo "[WARN] $dir exists"
    else
        echo "[INF] Cloning for $dir"
        git clone $repo_url $dir
    fi
}

# Check if zsh is installed
function is_zsh_installed {
    if [ -x "$(command -v zsh)" ]; then
        echo "[INF] zsh is installed"
        return 0
    fi
    echo "[ERR] zsh is not installed"
    return 1
}

# Ask the user if they want to install zsh
function ask_install_zsh {
    echo "[INF] Do you want to install zsh? (Y/n)"
    read -p "[INF] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_zsh
    else
        echo "[INF] Skipping zsh installation"
    fi
}

# Install zsh
function install_zsh {
    echo "[INF] Installing zsh"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "[INF] macOS detected"
        brew install zsh
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "[INF] Linux detected"
        sudo apt install zsh
    fi
}

# Main section of the script
function main {

    # change directory to ~
    cd ~

    # Check if zsh is installed
    if ! is_zsh_installed; then
        ask_install_zsh
    else
        echo "[INF] zsh is installed, proceeding with OSTYPE detection"
        echo "[INF] OSTYPE was detected as $OSTYPE"
    fi

    # Clone repositories
    clone_if_not_exists "${CUSTOM_ZSH}/plugins/zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
    clone_if_not_exists "${CUSTOM_ZSH}/plugins/zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    clone_if_not_exists "${HOME_ZSH}/themes/powerlevel10k" "https://github.com/romkatv/powerlevel10k.git"

    echo "[INF] Done"
    zsh
}

# Call the main function
main
