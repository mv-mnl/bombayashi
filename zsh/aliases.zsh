# --- Aliases ---

export PATH="$HOME/.local/bin:$PATH"

# Navegación
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias x='exit'
alias md='mkdir -p'

# Operaciones seguras
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'

# Colores en escala de grises para ls / eza
export LS_COLORS="di=1;37:ln=4;37:ex=0;37:bd=37:cd=37:su=37:sg=37:tw=37:ow=37"

# ls / eza
if command -v eza &>/dev/null; then
    alias ls='eza --color=always --icons=always --group-directories-first'
    alias ll='eza -lh --color=always --icons=always --group-directories-first'
    alias la='eza -lah --color=always --icons=always --group-directories-first'
    alias tree='eza --tree --level=2 --icons=always'
    alias treel='eza --tree --level=3 --icons=always'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah'
    alias la='ls -A'
fi

# bat
if command -v bat &>/dev/null; then
    alias cat='bat --theme=ansi'
fi

# grep
alias grep='grep --color=auto'

# Red y disco
alias ping='ping -c 5'
alias ports='sudo netstat -tulanp'
alias df='df -h'
alias free='free -m'

# Pacman / Yay
alias update='sudo pacman -Syu'
alias install='yay -S'
alias remove='yay -Rns'
alias search='yay -Ss'
alias orphan='yay -Qtdq | yay -Rns -'
alias rmpkg='sudo pacman -Rsn'
alias cleanch='sudo pacman -Scc'
alias fixpacman='sudo rm /var/lib/pacman/db.lck'
alias jctl='journalctl -p 3 -xb'
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# Build
alias make="make -j$(nproc)"
alias ninja="ninja -j$(nproc)"
alias n='ninja'

# Git
alias gs='git status -sb'
alias gd='git --no-pager diff --color-words --patch-with-stat'
alias gc='git add -A && git commit -m'
alias gp='git push origin $(git rev-parse --abbrev-ref HEAD)'
alias gcm='git switch'
alias gcr='git switch -c'
alias gca='git commit --amend'
alias gpf='git push --force-with-lease'
alias gb='git branch -vv --sort=-committerdate'

# Docker
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcr='docker compose restart'
alias dcb='docker compose build'
alias dcl='docker compose logs -f --tail=100'
alias dimg='docker images'
alias dnet='docker network ls'
alias dvol='docker volume ls'
alias dstopall='docker stop $(docker ps -q)'
alias drmall='docker rm $(docker ps -aq)'
alias dclean='docker system prune -af'
alias dvolclean='docker volume prune -f'

# Python
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias venv-on='source bin/activate'
alias venv-off='deactivate'

# Carpeta compartida
alias srv='cd /srv/compartido'
alias srvl='la /srv/compartido'
alias srvv='cd /srv/compartido/Vault'

# Misc
alias please='sudo'
alias tb='nc termbin.com 9999'
alias monitor="$HOME/.config/hypr/scripts/detect_machine.sh"
