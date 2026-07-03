# --- Keybindings ---
bindkey -e

bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

function delete-char-selection() {
  if (( REGION_ACTIVE )); then
    zle kill-region
  else
    zle delete-char
  fi
}
zle -N delete-char-selection
bindkey '^[[3~' delete-char-selection

function select-left() {
  (( REGION_ACTIVE )) || zle set-mark-command
  zle backward-char
}
function select-right() {
  (( REGION_ACTIVE )) || zle set-mark-command
  zle forward-char
}
function backward-delete-selection() {
  if (( REGION_ACTIVE )); then
    zle kill-region
  else
    zle backward-delete-char
  fi
}

zle -N select-left
zle -N select-right
zle -N backward-delete-selection

bindkey '^[[1;2H' beginning-of-line
bindkey '^[[1;2F' end-of-line
bindkey '^[[1;2D' select-left
bindkey '^[[1;2C' select-right
bindkey '^?' backward-delete-selection
