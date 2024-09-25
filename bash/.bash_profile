# export PATH="/usr/local/mysql/bin:$PATH"
export PATH=${PATH}:/usr/local/mysql-8.0.32-macos13-arm64/bin
. "$HOME/.cargo/env"
export PATH="/opt/homebrew/bin:$PATH"

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
