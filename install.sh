#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin main;

# verbose ln, because `ln -v` is not portable
symlink() {
	printf '%55s -> %s\n' "${1/#$HOME/\~}" "${2/#$HOME/\~}"
	ln -nsf "$@"
}

# NOTE: dotfiles config
dotfiles=(
	gitconfig
	tmux.conf
)

for f in "${dotfiles[@]}"; do
	[[ -d ~/.$f && ! -L ~/.$f ]] && rm -r ~/."$f"
	symlink "$PWD/$f" ~/."$f"
done

# NOTE: Bash config
bash_dotfiles=(
	extra
	path
	bash_prompt
	bash_profile
	bashrc
	exports
	aliases
	functions
	extra
	inputrc
)

for f in "${bash_dotfiles[@]}"; do
	[[ -d ~/.$f && ! -L ~/.$f ]] && rm -r ~/."$f"
	symlink "$PWD/bashrc/$f" ~/."$f"
done


# NOTE: application config folders
config_folders=(
	git
	iterm2
	nvim
	skhd
	yabai
)

# Check if ~/.config exists, and create it if it doesn't
if [[ ! -d ~/.config ]]; then
    mkdir ~/.config
    echo "Created ~/.config directory."
fi

for f in "${config_folders[@]}"; do
	[[ -d ~/.config/$f && ! -L ~/.config/$f ]] && rm -r ~/.config/"$f"
	symlink "$PWD/$f" ~/.config/"$f"
done
