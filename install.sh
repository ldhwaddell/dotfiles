#!/usr/bin/env bash

set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
dry_run=false
target_home=${DOTFILES_HOME:-$HOME}
backup_root="${DOTFILES_BACKUP_DIR:-$target_home/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"

usage() {
	cat <<'EOF'
Usage: ./install.sh [--dry-run]

  --dry-run  Show backups and links without changing the filesystem
EOF
}

while (($#)); do
	case "$1" in
		--dry-run) dry_run=true ;;
		-h | --help)
			usage
			exit 0
			;;
		*)
			printf 'Unknown option: %s\n' "$1" >&2
			usage >&2
			exit 2
			;;
	esac
	shift
done

run() {
	if $dry_run; then
		printf 'DRY-RUN:'
		printf ' %q' "$@"
		printf '\n'
	else
		"$@"
	fi
}

link_config() {
	local source=$1
	local target=$2
	local relative backup

	if [[ -L $target && $(readlink "$target") == "$source" ]]; then
		printf 'OK      %s -> %s\n' "$target" "$source"
		return
	fi

	if [[ -e $target || -L $target ]]; then
		relative=${target#"$target_home"/}
		backup="$backup_root/$relative"
		run mkdir -p "$(dirname "$backup")"
		run mv "$target" "$backup"
		printf 'BACKUP  %s -> %s\n' "$target" "$backup"
	fi

	run mkdir -p "$(dirname "$target")"
	run ln -s "$source" "$target"
	printf 'LINK    %s -> %s\n' "$target" "$source"
}

for name in gitconfig; do
	link_config "$repo_dir/tools/$name" "$target_home/.$name"
done

for name in path bash_prompt bash_profile bashrc exports aliases functions inputrc; do
	link_config "$repo_dir/tools/bashrc/$name" "$target_home/.$name"
done

for name in nvim ghostty; do
	link_config "$repo_dir/tools/$name" "$target_home/.config/$name"
done

# lazygit keeps state.yml and other runtime files next to its config, so link
# only the config file instead of the whole directory.
link_config "$repo_dir/tools/lazygit/config.yml" "$target_home/Library/Application Support/lazygit/config.yml"

# vim.pack installs any missing plugins from nvim-pack-lock.json on startup.
if command -v nvim >/dev/null 2>&1; then
	printf 'BOOTSTRAP nvim plugins (vim.pack)\n'
	if ! run nvim --headless +qa; then
		printf 'WARNING: plugin bootstrap failed; run nvim and check :checkhealth vim.pack\n' >&2
	fi
else
	printf 'SKIP    nvim plugins (nvim not on PATH)\n'
fi
