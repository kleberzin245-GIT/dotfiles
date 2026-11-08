# ~/.config/shell/rice.sh  (carregado pelo ~/.bashrc e ~/.zshrc)
# só em shell interativo
case $- in *i*) ;; *) return 0 2>/dev/null ;; esac

# prompt
if command -v starship >/dev/null 2>&1; then
  if   [ -n "$BASH_VERSION" ]; then eval "$(starship init bash)"
  elif [ -n "$ZSH_VERSION" ];  then eval "$(starship init zsh)"
  fi
fi

# eza no lugar de ls (as cores seguem a paleta do terminal, que vem do matugen)
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first --git'
  alias la='eza -la --icons --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons --group-directories-first'
fi

# bat no lugar de cat (tema "ansi" = usa as cores do terminal)
if command -v bat >/dev/null 2>&1; then
  export BAT_THEME=ansi
  alias cat='bat --paging=never --style=plain'
  alias catn='bat'          # com números de linha, grade e paginação
fi

# fastfetch com as cores do tema
command -v fastfetch >/dev/null 2>&1 && alias ff='fastfetch'
# para rodar ao abrir cada terminal, descomente:
# command -v fastfetch >/dev/null 2>&1 && fastfetch
