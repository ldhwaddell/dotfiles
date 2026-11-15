#!/usr/bin/env bash

set -euo pipefail

apply=false

usage() {
	cat <<'EOF'
Usage: ./macos.sh [--apply]

Without --apply, commands are printed and no preferences are changed.
EOF
}

while (($#)); do
	case "$1" in
		--apply) apply=true ;;
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
	if $apply; then
		"$@"
	else
		printf 'PREVIEW:'
		printf ' %q' "$@"
		printf '\n'
	fi
}

# Keyboard and global UI

# Screenshots
	run defaults write NSGlobalDomain AppleHighlightColor -string '0.764700 0.976500 0.568600'
	run defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
	run defaults write NSGlobalDomain KeyRepeat -int 2
	run defaults write NSGlobalDomain InitialKeyRepeat -int 12
run defaults write com.apple.screencapture type -string png

# Finder
run defaults write com.apple.finder NewWindowTarget -string PfDe
run defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/Desktop/"
run defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
run defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
run defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
run defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
run defaults write NSGlobalDomain AppleShowAllExtensions -bool true
run defaults write com.apple.finder ShowStatusBar -bool true
run defaults write com.apple.finder ShowPathbar -bool true
run defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
run defaults write com.apple.finder _FXSortFoldersFirst -bool true
run defaults write com.apple.finder FXDefaultSearchScope -string SCcf
run defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
run defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
run defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
run defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
run defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
run defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Dock and Mission Control
run defaults write com.apple.dock expose-animation-duration -float 0.1
run defaults write com.apple.dock mru-spaces -bool false
run defaults write com.apple.dock autohide-delay -float 0
run defaults write com.apple.dock autohide-time-modifier -float 0

# Activity Monitor
run defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
run defaults write com.apple.ActivityMonitor IconType -int 5
run defaults write com.apple.ActivityMonitor ShowCategory -int 0
run defaults write com.apple.ActivityMonitor SortColumn -string CPUUsage
run defaults write com.apple.ActivityMonitor SortDirection -int 0

# TextEdit and connected devices
run defaults write com.apple.TextEdit RichText -int 0
run defaults write com.apple.TextEdit PlainTextEncoding -int 4
run defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
run defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

if [[ -d '/Applications/Google Chrome.app' ]]; then
	run defaults write com.google.Chrome DisablePrintPreview -bool true
	run defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
fi

if $apply; then
	for app in 'Activity Monitor' Dock Finder 'Google Chrome'; do
		pgrep -x "$app" >/dev/null 2>&1 && killall "$app" >/dev/null 2>&1 || true
	done
	printf 'macOS preferences applied. Some changes may require logging out.\n'
else
	printf 'Preview only. Re-run with --apply to change preferences.\n'
fi
