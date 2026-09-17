export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="bira"

plugins=(
    fzf
    zsh-autosuggestions
    history-substring-search
)

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
VIRTUAL_ENV_DISABLE_PROMPT=1

export BROWSER=zen
export TERMINAL=kitty
export BAT_THEME=ansi
export PATH=$PATH:~/.cargo/bin/
export PATH=$PATH:~/.local/bin/
export EDITOR=hx
export VISUAL=hx
export SUDO_EDITOR=hx

# OS-Specific Configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (Homebrew & hx)
    [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"


elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export ANDROID_HOME="/opt/android-sdk"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
fi

# Add SDK components to PATH
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin

alias fastfetch="fastfetch -l ~/dotfiles/ascii/skull.txt --logo-color-1 yellow"
alias ssh="kitty +kitten ssh"
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -alF --icons --color=always --group-directories-first'
alias la='eza -a --icons --color=always --group-directories-first'
alias l.='eza -a | egrep "^\."'
alias py="python"
alias g=git

set -o vi
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -v
zstyle :compinstall filename '/home/brage/.zshrc'

autoload -Uz compinit
compinit

eval "$(zoxide init zsh)"
