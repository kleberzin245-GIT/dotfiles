# Como contribuir neste rice

## O que funciona

- `./install.sh` — detecta a distro; instala automaticamente no Arch e imprime o guia manual nas demais.
- `./bootstrap.sh` — configuração do Arch em uma máquina nova.
- `./dotsave "mensagem"` — commita e empurra as mudanças.
- `rice/.config/hypr/scripts/menu.sh` — menu de controle (SUPER+M).

## Regras de contribuição

### 1. Não faça commit de dados sensíveis

O `hooks/pre-commit` bloqueia tentativas de commit com senhas, tokens ou
chaves de API. Certifique-se de que o hook está ativo:

```bash
ln -sf ../../hooks/pre-commit .git/hooks/pre-commit
```

Depois, os commits são revistos antes de subir.

### 2. Mantenha a separação

- **Configs geradas** (cores do Matugen, `starship.toml`, `fastfetch/config.jsonc`) são
  defaults commitados; o matugen os regenerate em wallpaper.
- **Arquivos manuais** (configurações do Hyprland, binds, scripts) podem ser versionados.

### 3. Testes antes de abrir PR

- `bash -n` e `shellcheck -S warning` em todo script shell adicionado.
- `python3 -m py_compile rice/.config/rice/scripts/style-render.py`.
- Se mexer no Quickshell: `qmllint rice/.config/quickshell/**/*.qml`.
- Rode `style-render.py --all` e confirme que `~/.local/state/rice/` é gerado.
- Troque de estilo no menu e confirme que `Waybar`/`Kitty` reagem.
- Teste o `dotsave` e o `pull` em uma máquina limpa.

### 4. Documente

Se você adicionar uma funcionalidade nova, explique o fluxo de configuração no
`docs/ARCHITECTURE.md` e nos `docs/installation.md` se necessário.

---

Feito com ❤️ e muito Linux.
