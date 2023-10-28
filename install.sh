#!/bin/bash

# Define constants
CUSTOM_ZSH="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"
HOME_ZSH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
NYZ_DIR=$(pwd)

# log, recieve type and message
_log() {
    local type=$1
    local message=$2
    echo "[$type] $message"
    echo "[$type] $(date '+%Y-%m-%d %H:%M:%S'): $message" >> "$NYZ_DIR/.log"
}

is_os_supported() {
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
        _log "INF" "OS is supported"
        return 0
    fi
    _log "ERR" "OS is not supported"
    return 1
}

# Clone the repository if it does not exist in the directory
clone_if_not_exists() {
    local dir=$1
    local repo_url=$2
    if [ -d "$dir" ]; then
        _log "INF" "$dir exists"
        return 0
    fi
    _log "INF" "Cloning for $dir"
    git clone $repo_url $dir
}

# Check if zsh is installed
is_zsh_installed() {
    ost=${OSTYPE:-unknown}
    if [ -x "$(command -v zsh)" ]; then
        _log "INF" "zsh is installed"
        _log "INF" "Proceeding with OSTYPE detection"
        _log "INF" "OSTYPE was detected as $ost"
        return 0
    fi
    _log "WARN" "zsh is not installed"
    return 1
}

# Ask the user if they want to install zsh
ask_install_zsh() {
    _log "INF" "Do you want to install zsh? (Y/n))"
    read -p "[INF] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        return 0
    fi
    _log "INF" "Skipping zsh installation"
    return 1
}

# Install zsh
install_zsh() {
    _log "INF" "Installing zsh ..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        _log "INF" "macOS detected"
        brew install zsh &
        wait
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        _log "INF" "linux detected"
        sudo apt install zsh &
        wait
    fi
}

is_omz_installed() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        _log "INF" "oh-my-zsh is installed"
        return 0
    fi
    _log "ERR" "oh-my-zsh is not installed"
    return 1
}

install_omz() {
    _log "INF" "Installing oh-my-zsh ..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

zshrc_exsits() {
    if [ -f "$HOME/.zshrc" ]; then
        _log "INF" "zshrc exists"
        return 0
    fi
    _log "ERR" "zshrc does not exist"
    return 1
}

ask_overwrite_zshrc() {
    _log "INF" "Do you want to overwrite ~/.zshrc? (Y/n)"
    read -p "[INF] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        overwrite_zshrc
    else
        _log "INF" "Skipping zshrc overwrite"
    fi
}

overwrite_zshrc() {
    local dir=$1
    _log "INF" "Overwriting zshrc ..."
    cp "$NYZ_DIR/.zshrc" "$HOME/.zshrc"
}

add_plugins() {
    local name=$1
    if [ -z "$(grep "$name" "$HOME/.zshrc")" ]; then
        _log "INF" "Adding $name to ~/.zshrc"
        sed -i -e "/^plugins=(/a$name" "$HOME/.zshrc"
    else
        _log "INF" "$name already exists in ~/.zshrc"
    fi
}

# Main section of the script
main() {

    local repos=(
        "zsh-autosuggestions ${CUSTOM_ZSH}/plugins/zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting ${CUSTOM_ZSH}/plugins/zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "powerlevel10k ${HOME_ZSH}/themes/powerlevel10k https://github.com/romkatv/powerlevel10k.git"
        # add more plugins here ...
        # format: "name path git_url"
    )

    # Create log file
    touch ./.log

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

    # Overwriting zshrc
    if (zshrc_exsits); then
        ask_overwrite_zshrc
    else
        overwrite_zshrc
    fi

    # Installing plugins
    for repo in "${repos[@]}"; do
        IFS=" " read -r name path url <<<"${repo}"
        clone_if_not_exists "$path" "$url"
        # if path is /theme/ then not a plugin
        if [[ "$path" != *"/themes/"* ]]; then
            add_plugins "$name"
        fi
    done

    _log "INF" "Restaring zsh ..."
    zsh
}

# Call the main function
main
