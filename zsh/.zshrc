# Initialisation

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

autoload -Uz compinit
compinit

# Environment Variables

export EDITOR='nvim'
export PATH="$HOME/Applications:$PATH"

# Plugin Manager

source /usr/share/zsh-antidote/antidote.zsh
antidote load

# Keybindings & Shell Integrations

bindkey -v
if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
fi
eval "$(starship init zsh)"
eval $(thefuck --alias fuck)

# Aliases

alias ls='lsd'
alias vim='nvim'
alias grep='grep --color=auto'

# On Startup
clear && fastfetch
