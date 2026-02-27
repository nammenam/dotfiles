
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
export BAT_THEME=hexsteel
export PATH=$PATH:~/.cargo/bin/

alias py="python"
alias hx="helix"
alias uiologin="ssh -YC bragewi@login.uio.no"
alias uiofolder="sshfs bragewi@login.uio.no: /home/brage/IFI -o reconnect,modules=iconv,from_code=utf8"
alias fastfetch="fastfetch -l ~/dotfiles/ascii/skull.txt --logo-color-1 yellow"
alias ls='exa --icons --color=always --group-directories-first'
alias ll='exa -alF --icons --color=always --group-directories-first'
alias la='exa -a --icons --color=always --group-directories-first'
alias l='exa -F --icons --color=always --group-directories-first'
alias l.='exa -a | egrep "^\."'

set -o vi
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
zstyle :compinstall filename '/home/brage/.zshrc'

autoload -Uz compinit
compinit

eval "$(zoxide init zsh)"
