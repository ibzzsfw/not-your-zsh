clone_if_not_exists() {
    dir=$1
    repo_url=$2
    if [ -d "$dir" ]; then
        echo "[WARN] $dir exists"
    else
        echo "[INF] cloning for $dir"
        git clone $repo_url $dir
    fi
}

# function to check if zsh is installed, return boolean
is_zsh_installed() {
    if [ -x "$(command -v zsh)" ]; then
        echo "[INF] zsh is installed"
        return 0
    fi
    echo "[ERR] zsh is not installed"

    return 1
}

# function to ask user to install zsh
ask_install_zsh() {
    echo "[INF] Do you want to install zsh? (Y/n)"
    read -p "[INF] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "[INF] installing zsh"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "[INF] macOS detected"
            brew install zsh
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "[INF] Linux detected"
            sudo apt install zsh
        fi
    else
        echo "[INF] skipping zsh installation"
    fi
}

CUSTOM_ZSH=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
HOME_ZSH=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# check if zsh is installed,
# if not, ask user to install zsh
# else, continue

if ! is_zsh_installed; then
    ask_install_zsh
else
    echo "[INF] zsh is installed"
    echo "[INF] OSTYPE was detected as $OSTYPE"
fi

clone_if_not_exists "${CUSTOM_ZSH}/plugins/zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
clone_if_not_exists "${CUSTOM_ZSH}/plugins/zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
clone_if_not_exists "${HOME_ZSH}/themes/powerlevel10k" "https://github.com/romkatv/powerlevel10k.git"
# add more plugins here ...

echo "[INF] running zsh..."

zsh

echo "[INF] done"
