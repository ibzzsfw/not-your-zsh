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
    exit 1
}

# Clone the repository if it does not exist in the directory
clone_if_not_exists() {
    local dir=$1
    local repo_url=$2
    if [ -d "$dir" ]; then
        log_message "INF" "$dir exists"
    else
        log_message "INF" "Cloning for $dir"
        git clone $repo_url $dir
    fi
}

# Check if zsh is installed
is_zsh_installed() {
    if [ -x "$(command -v zsh)" ]; then
        log_message "INF" "zsh is installed"
        log_message "INF" "Proceeding with OSTYPE detection"
        log_message "INF" "OSTYPE was detected as $OSTYPE"
        return 0
    fi
    log_message "ERR" "zsh is not installed"
    ask_install_zsh
}

# Ask the user if they want to install zsh
ask_install_zsh() {
    log_message "INF" "Do you want to install zsh? (y/n, Press Enter for Yes)"
    read -p "[INF] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        install_zsh
        return 0
    else
        log_message "INF" "Skipping zsh installation"
        exit 1
    fi
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

# Main section of the script
main() {

    # change directory to ~
    cd ~

    # os compatibility
    is_os_supported

    # Check if zsh is installed
    is_zsh_installed

    local repos=(
        "${CUSTOM_ZSH}/plugins/zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions"
        "${CUSTOM_ZSH}/plugins/zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "${HOME_ZSH}/themes/powerlevel10k https://github.com/romkatv/powerlevel10k.git"
        # add more plugins here ...
    )

    for repo in "${repos[@]}"; do
        IFS=" " read -r path url <<<"${repo}"
        clone_if_not_exists "$path" "$url"
    done

    log_message "INF" "Restaring zsh ..."
    zsh
}

# Call the main function
main
