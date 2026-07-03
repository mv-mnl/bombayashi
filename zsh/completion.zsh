# --- Completion ---
autoload -Uz compinit
compinit -d "$HOME/.cache/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
setopt always_to_end
setopt glob_dots
setopt auto_cd
setopt no_beep
