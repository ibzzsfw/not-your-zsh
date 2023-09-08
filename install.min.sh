CUSTOM_ZSH="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"
HOME_ZSH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
function log_message {
    local type=$1
    local message=$2
    echo "[$type] $(date): $message"
}
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
function main {
    cd ~
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
        log_message "INF" "OS is supported"
        return 0
    fi
    log_message "ERR" "OS is not supported"
    exit 1
    if [ -x "$(command -v zsh)" ]; then
        log_message "INF" "zsh is installed"
        log_message "INF" "Proceeding with OSTYPE detection"
        log_message "INF" "OSTYPE was detected as $OSTYPE"
        return 0
    fi
    log_message "ERR" "zsh is not installed"
    log_message "INF" "Do you want to install zsh? (y/n, Press Enter for Yes)"
    read -p "[INF] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        log_message "INF" "Installing zsh ..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            log_message "INF" "macOS detected"
            brew install zsh
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            log_message "INF" "linux detected"
            sudo apt install zsh
        fi
        return 0
    else
        log_message "INF" "Skipping zsh installation"
        exit 1
    fi
    local repos=(
        "${CUSTOM_ZSH}/plugins/zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions"
        "${CUSTOM_ZSH}/plugins/zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "${HOME_ZSH}/themes/powerlevel10k https://github.com/romkatv/powerlevel10k.git"
        # add more plugins here ...
    )
    for repo in "${repos[@]}"; do
        IFS=" " read -r path url <<<"${repo}"
        if [ -d "$dir" ]; then
            log_message "INF" "$path exists"
        else
            log_message "INF" "Cloning for $path"
            git clone $repo $path
        fi
    done
    log_message "INF" "Restaring zsh ..."
    zsh
}
main
