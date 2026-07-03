# --- Funciones ---

# Crea directorio y entra en él
mk() {
  mkdir -p "$1" && cd "$1"
}

# Resumen rápido del repo git actual
git_resumen() {
  echo -e "\n--- RAMAS ---"
  git branch -a
  echo -e "\n--- ÚLTIMOS CAMBIOS ---"
  git log -n 5 --oneline --graph --color
  echo -e "\n--- ESTADO ---"
  git status -s
}
alias gr='git_resumen'

# Log bonito con grafo
gl() {
  local limite=${1:-100}
  git --no-pager log -n "$limite" --graph --abbrev-commit --decorate \
    --format=format:'%C(bold white)%h%C(reset) - %C(dim white)%aD%C(reset) %C(dim white)(%ar)%C(reset)%C(bold white)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all
}

# Git add fuzzy
gaf() {
  local files
  files=$(git status -s | fzf -m --ansi --preview 'git diff --color=always -- {-1}' | awk '{print $NF}')
  [[ -n $files ]] && echo "$files" | xargs git add && git status -s
}

# Git checkout fuzzy (ramas)
gcf() {
  local branch
  branch=$(git branch --all | grep -v 'HEAD' | fzf +m --ansi \
    --preview 'git log --oneline --graph --color=always --count=50 {1}')
  [[ -n $branch ]] && git checkout "${branch//[* ]/}"
}

# Git log fuzzy con preview de cambios
glf() {
  git log --graph --color=always --format="%C(bold white)%h%d %s %C(dim white)%cr" "$@" | \
  fzf --ansi --no-sort --reverse --tiebreak=index \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 | \
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF" \
      --preview "grep -o '[a-f0-9]\{7\}' <<< {} | head -1 | xargs git show --color=always"
}

# Checkout de archivo específico fuzzy
gco() {
  local files
  files=$(git ls-files --modified --others --exclude-standard | \
    fzf -m --ansi --preview 'git diff --color=always -- {}')
  [[ -n $files ]] && echo "$files" | xargs git checkout && git status -s
}

# Muestra uso de disco del directorio actual
espacio() {
  local bright="\e[1;37m" dim="\e[2m" reset="\e[0m" bold="\e[1m"

  echo -e "\n${bright}╭───────────────────────────────────────────────────────╮${reset}"
  echo -e "${bright}│${reset} 💽 ${bold}ESTADO DE LOS DISCOS PRINCIPALES${reset}                    ${bright}│${reset}"
  echo -e "${bright}╰───────────────────────────────────────────────────────╯${reset}\n"

  df -hT -x tmpfs -x devtmpfs -x squashfs 2>/dev/null | awk '
  NR==1 {
    printf "  \033[1;37m%-16s %-10s %-8s %-8s %-8s %s\033[0m\n", "SISTEMA", "TIPO", "TOTAL", "USADO", "LIBRE", "USO%"
    print "  \033[2m------------------------------------------------------------------\033[0m"
  }
  NR>1 {
    weight = "\033[0m"
    uso = $6 + 0
    if (uso > 75) weight = "\033[1m"
    if (uso > 90) weight = "\033[7m"
    printf "  %-16s %-10s %-8s %-8s %-8s " weight "%-5s\033[0m %s\n", substr($1,1,15), substr($2,1,9), $3, $4, $5, $6, $7
  }'

  echo -e "\n${bright}╭───────────────────────────────────────────────────────╮${reset}"
  echo -e "${bright}│${reset} 📂 ${bold}TOP 10 MÁS PESADOS EN EL DIRECTORIO ACTUAL${reset}          ${bright}│${reset}"
  echo -e "${bright}╰───────────────────────────────────────────────────────╯${reset}"
  echo -e "  📍 ${dim}Ruta: $PWD${reset}\n"

  du -ah --max-depth=1 2>/dev/null | sort -rh | head -n 11 | awk '
  NR==1 {
    printf "  \033[1;37m%-10s %s\033[0m\n", "TAMAÑO", "ARCHIVO / CARPETA (TOTAL)"
    print "  \033[2m------------------------------------------------------------------\033[0m"
    printf "  \033[7m%-10s\033[0m %s\n", $1, $2
  }
  NR>1 { printf "  \033[1m%-10s\033[0m %s\n", $1, $2 }'

  echo ""
  if command -v dust &>/dev/null; then
    echo -e "  🚀 ${bold}Tip:${reset} Tienes ${bold}dust${reset} instalado. ¡Escribe 'dust' para una vista de árbol brutal!"
  elif command -v ncdu &>/dev/null; then
    echo -e "  💡 ${bold}Tip:${reset} Tienes ${bold}ncdu${reset}. Escribe 'ncdu' para navegar interactivamente."
  fi
  echo ""
}
