# Define constants
CUSTOM_ZSH="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"
HOME_ZSH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# log, recieve type and message
function log_message {
    local type=$1
    local message=$2
    echo "[$type] $(date): $message"
}

# Clone the repository if it does not exist in the directory
function clone_if_not_exists {
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
function is_zsh_installed {
    if [ -x "$(command -v zsh)" ]; then
        log_message "INF" "zsh is installed"
        return 0
    fi
    log_message "ERR" "zsh is not installed"
    return 1
}

# Ask the user if they want to install zsh
function ask_install_zsh {
    log_message "INF" "Do you want to install zsh? (y/n, Press Enter for Yes)"
    read -p "[INF] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        install_zsh
    else
        log_message "INF" "Skipping zsh installation"
        exit 1
    fi
}

# Install zsh
function install_package_mac {
    log_message "INF" "macOS: Installing $1"
    brew install $1
}

function install_package_linux {
    log_message "INF" "linux detected: Installing $1"
    sudo apt install $1
}

function install_zsh {
    local os=$(uname)
    log_message "INF" "Installing zsh"

    if [[ "$os" == "Darwin" ]]; then
        installer=install_package_mac
    else
        installer=install_package_linux
    fi

    $installer zsh
}

# Main section of the script
function main {

    # change directory to ~
    cd ~

    # if os legitable
    if [[ "$OSTYPE" != "darwin"* ]] && [[ "$OSTYPE" != "linux-gnu"* ]]; then
        log_message "ERR" "Unsupported OS"
        exit 1
    fi

    # Check if zsh is installed
    if ! is_zsh_installed; then
        ask_install_zsh
    else
        log_message "INF" "Proceeding with OSTYPE detection"
        log_message "INF" "OSTYPE was detected as $OSTYPE"
    fi

    # Clone repositories
    clone_if_not_exists "${CUSTOM_ZSH}/plugins/zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
    clone_if_not_exists "${CUSTOM_ZSH}/plugins/zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    clone_if_not_exists "${HOME_ZSH}/themes/powerlevel10k" "https://github.com/romkatv/powerlevel10k.git"

    log_message "INF" "Done"
    zsh
}

# Call the main function
main
