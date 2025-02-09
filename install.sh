#!/usr/bin/env interpreter

# setup
sudo dnf copr enable atim/lazygit -y
packages = (fzf zsh neovim tmux kitty lazygit nnn)
sudo dnf install packages 

curl -sS https://starship.rs/install.sh | sh
curl -sS Anaconda3-2024.10-1-Linux-x86_64.sh | sh
