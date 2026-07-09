export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="customagnoster"
ZSH_THEME="bira"

plugins=(
    fzf
    git
    zsh-autosuggestions
    history-substring-search
)

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
VIRTUAL_ENV_DISABLE_PROMPT=1
export EDITOR=helix
export BROWSER=zen
export TERMINAL=kitty
export TERM=kitty
export SUDO_EDITOR=helix
export VISUAL=helix
export BAT_THEME=ansi
export _JAVA_AWT_WM_NONREPARENTING=1
export PATH=$PATH:~/.cargo/bin/
export PATH=$PATH:~/.local/bin/
export PATH=$PATH:~/.local/share/vivado/2025.2/Vivado/bin/
export PATH=$PATH:~/.local/share/vivado/2025.2/Vitis/bin/


alias fastfetch="fastfetch -l ~/dotfiles/ascii/skull.txt --logo-color-1 yellow"
alias ssh="kitty +kitten ssh"
alias ls='exa --icons --color=always --group-directories-first'
alias ll='exa -alF --icons --color=always --group-directories-first'
alias la='exa -a --icons --color=always --group-directories-first'
alias l='exa -F --icons --color=always --group-directories-first'
alias l.='exa -a | egrep "^\."'
alias py="python"
alias hx="helix"
alias tt="taskwarrior-tui"

set -o vi
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -v
zstyle :compinstall filename '/home/brage/.zshrc'

autoload -Uz compinit
compinit

eval "$(zoxide init zsh)"
