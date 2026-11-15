#!/usr/bin/env bash

set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
brewfile="$repo_dir/Brewfile"
upgrade=false
set_shell=false

usage() {
	cat <<'EOF'
Usage: ./brew.sh [--upgrade] [--set-shell]

  --upgrade    Update Homebrew, Brewfile packages, and stable Rust
  --set-shell  Register Homebrew Bash and make it the login shell
EOF
}

while (($#)); do
	case "$1" in
		--upgrade) upgrade=true ;;
		--set-shell) set_shell=true ;;
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

if ! command -v brew >/dev/null 2>&1; then
	printf 'Homebrew is required: https://brew.sh\n' >&2
	exit 1
fi

if $upgrade; then
	brew update
	brew bundle install --upgrade --file="$brewfile"
else
	brew bundle install --no-upgrade --file="$brewfile"
fi

rustup_bin="$(brew --prefix rustup)/bin"
export PATH="$rustup_bin:$HOME/.cargo/bin:$PATH"

if $upgrade; then
	rustup update stable
elif ! rustup show active-toolchain >/dev/null 2>&1; then
	rustup default stable
fi

rustup component add rust-analyzer rustfmt

if $set_shell; then
	brew_bash="$(brew --prefix)/bin/bash"
	if ! grep -Fxq "$brew_bash" /etc/shells; then
		printf '%s\n' "$brew_bash" | sudo tee -a /etc/shells >/dev/null
	fi
	if [[ ${SHELL:-} != "$brew_bash" ]]; then
		chsh -s "$brew_bash"
	fi
fi

printf '\nBrewfile cleanup preview (nothing will be removed):\n'
brew bundle cleanup --no-cask --no-tap --file="$brewfile" || true
