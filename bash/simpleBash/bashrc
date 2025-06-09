#
# ~/.bashrc
#

#Colors
RESET="\[\e[0m\]"
FG_BLACK="\[\e[38;5;0m\]"
FG_WHITE="\[\e[38;5;15m\]"
FG_GREEN="\[\e[38;5;34m\]"
FG_BLUE="\[\e[38;5;33m\]"
FG_MAGENTA="\[\e[38;5;163m\]"
FG_YELLOW="\[\e[38;5;220m\]"
BG_GREEN="\[\e[48;5;34m\]"
BG_BLUE="\[\e[48;5;33m\]"
BG_MAGENTA="\[\e[48;5;163m\]"
BG_YELLOW="\[\e[48;5;220m\]"
BG_GRAY="\[\e[48;5;236m\]"

parse_git_branch() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  echo "  $branch"
}

PS1="\[\e[1;38;5;39m\] \u\[\e[0m\] in \[\e[1;38;5;111m\]\w\[\e[0m\]\[\e[38;5;245m\]\$(parse_git_branch)\[\e[0m\] ❯ "

#fzf as a default history searcher

__fzf_history_search__() {
  local selected
  selected=$(history | tac | fzf --height=40% --reverse --border --prompt='History > ' | sed 's/^[ ]*[0-9]*[ ]*//')
  if [[ -n "$selected" ]]; then
    READLINE_LINE="$selected"
    READLINE_POINT=${#selected}
  fi
}

bind -x '"\C-r": __fzf_history_search__'

#Aliases

alias ..="cd .."
alias ...="cd ../.."
alias ls="ls --color=auto"
alias ll="ls -alF --color=auto"
alias la="ls -A --color=auto"
alias l="ls -CF --color=auto"
alias v="nvim"
alias cat="bat --style=plain --paging=never 2>/dev/null || cat"
alias grep="grep --color=auto"

#History Settings

export HISTCONTROL=ignoredups
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize
shopt -s cmdhist

#Completion settings

bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

#Cool startup for some tools

export EDITOR=nvim
export VISUAL=nvim
export FZF_DEFAULT_COMMAND='find . -type f'

cd ~

# Enable bash completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi


