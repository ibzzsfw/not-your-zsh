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

CUSTOM_ZSH=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
HOME_ZSH=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

clone_if_not_exists "${CUSTOM_ZSH}/plugins/zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
clone_if_not_exists "${CUSTOM_ZSH}/plugins/zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
clone_if_not_exists "${HOME_ZSH}/themes/powerlevel10k" "https://github.com/romkatv/powerlevel10k.git"

zsh