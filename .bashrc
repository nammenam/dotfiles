# ==========================================
# Terminal Settings & History
# ==========================================
# Enable colored output for native commands
export CLICOLOR=1
export LSCOLORS="GxfxcxdxBxegedabagacad" # macOS
export LS_COLORS="di=1;34:ln=36:so=35:pi=33:ex=32:bd=35;01:cd=33;01:or=31;01:mi=01;31:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=30;41:" # Linux

# History settings: ignore duplicates and increase size
export HISTSIZE=10000
export HISTFILESIZE=10000
shopt -s histappend
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

# ==========================================
# Aliases
# ==========================================
alias ll="ls -lF"
alias la="ls -A"
alias l="ls -CF"
alias grep="grep --color=auto"
alias ..="cd .."
alias ...="cd ../.."

# ==========================================
# Elegant Prompt Configuration
# ==========================================
parse_git_branch() {
    local branch
    if branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then
        if [[ "$branch" == "HEAD" ]]; then
            branch="detached"
        fi
        echo -e " \e[35m $branch\e[0m"
    fi
}

set_bash_prompt() {
    # Color variables
    local NONE="\[\e[0m\]"
    local BLACK="\[\e[0;30m\]"
    local RED="\[\e[0;31m\]"
    local GREEN="\[\e[0;32m\]"
    local YELLOW="\[\e[0;33m\]"
    local BLUE="\[\e[0;34m\]"
    local PURPLE="\[\e[0;35m\]"
    local CYAN="\[\e[0;36m\]"
    local WHITE="\[\e[0;37m\]"
    local BOLD_BLUE="\[\e[1;34m\]"

    # \n for two-line layout. Line 1: User@Host (if SSH), Path, and Git status.
    PS1="${BOLD_BLUE}┌─${NONE}[$YELLOW\u$NONE@$CYAN\h$NONE] $BLUE\w$NONE"
    PS1+="\$(parse_git_branch)$NONE"
    PS1+="\n${BOLD_BLUE}└─▶${NONE} "
}

PROMPT_COMMAND=set_bash_prompt
