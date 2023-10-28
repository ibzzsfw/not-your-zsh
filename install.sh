#!/bin/bash

# Define constants
CUSTOM_ZSH="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"
HOME_ZSH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# log, recieve type and message
log_message() {
    local type=$1
    local message=$2
    echo "[$type] $(date): $message"
}

is_os_supported() {
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
        log_message "INF" "OS is supported"
        return 0
    fi
    log_message "ERR" "OS is not supported"
    return 1
}

# Clone the repository if it does not exist in the directory
clone_if_not_exists() {
    local dir=$1
    local repo_url=$2
    if [ -d "$dir" ]; then
        log_message "INF" "$dir exists"
        return 0
    fi
    log_message "INF" "Cloning for $dir"
    git clone $repo_url $dir
}

# Check if zsh is installed
is_zsh_installed() {
    ost=${OSTYPE:-unknown}
    if [ -x "$(command -v zsh)" ]; then
        log_message "INF" "zsh is installed"
        log_message "INF" "Proceeding with OSTYPE detection"
        log_message "INF" "OSTYPE was detected as $ost"
        return 0
    fi
    log_message "WARN" "zsh is not installed"
    return 1
}

# Ask the user if they want to install zsh
ask_install_zsh() {
    log_message "INF" "Do you want to install zsh? (Y/n))"
    read -p "[INF] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        return 0
    fi
    log_message "INF" "Skipping zsh installation"
    return 1
}

# Install zsh
install_zsh() {
    log_message "INF" "Installing zsh ..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_message "INF" "macOS detected"
        brew install zsh
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        log_message "INF" "linux detected"
        sudo apt install zsh
    fi
}

is_omz_installed() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_message "INF" "oh-my-zsh is installed"
        return 0
    fi
    log_message "ERR" "oh-my-zsh is not installed"
    return 1
}

install_omz() {
    log_message "INF" "Installing oh-my-zsh ..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

overwrite_zshrc() {
    local dir=$1
    log_message "INF" "Overwriting zshrc ..."
    cp "$dir/.zshrc" "$HOME/.zshrc"
}

add_plugins() {
    local name=$1
    if [ -z "$(grep "$name" "$HOME/.zshrc")" ]; then
        log_message "INF" "Adding $name to ~/.zshrc"
        sed -i -e "/^plugins=(/a$name" "$HOME/.zshrc"
    else
        log_message "INF" "$name already exists in ~/.zshrc"
    fi
}

# Main section of the script
main() {

    local dir=$(pwd)
    local repos=(
        "zsh-autosuggestions ${CUSTOM_ZSH}/plugins/zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting ${CUSTOM_ZSH}/plugins/zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "powerlevel10k ${HOME_ZSH}/themes/powerlevel10k https://github.com/romkatv/powerlevel10k.git"
        # add more plugins here ...
        # format: "name path git_url"
    )

    # change directory to ~
    cd ~

    # os compatibility
    if (! is_os_supported); then
        exit 1
    fi

    # Installing zsh
    if (! is_zsh_installed); then
        if (! ask_install_zsh); then
            exit 1
        fi
        install_zsh
    fi

    # Installing oh-my-zsh
    if (! is_omz_installed); then
        install_omz
    fi

    overwrite_zshrc "$dir"

    # Installing plugins
    for repo in "${repos[@]}"; do
        IFS=" " read -r name path url <<<"${repo}"
        clone_if_not_exists "$path" "$url"
        # if path is /theme/ then not a plugin
        if [[ "$path" != *"/themes/"* ]]; then
            add_plugins "$name"
        fi
    done

    log_message "INF" "Restaring zsh ..."
    zsh
}

# Call the main function
main
