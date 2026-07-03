# --- Plugins ---

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh 2>/dev/null
source /usr/share/doc/pkgfile/command-not-found.zsh 2>/dev/null

# Colores en escala de grises (aclarados para contraste sobre fondo oscuro)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=252'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=244,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=250'
ZSH_HIGHLIGHT_STYLES[alias]='fg=253'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=253'
ZSH_HIGHLIGHT_STYLES[function]='fg=253'
ZSH_HIGHLIGHT_STYLES[command]='fg=255,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=252,italic'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=244'
ZSH_HIGHLIGHT_STYLES[path]='fg=248,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=246'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=246'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=246'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=246'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=250'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=250'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=250'
ZSH_HIGHLIGHT_STYLES[assign]='fg=246'
ZSH_HIGHLIGHT_STYLES[comment]='fg=242,italic'

# Zoxide
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# FZF
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
