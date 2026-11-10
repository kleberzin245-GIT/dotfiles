# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).

## [Não lançado]

### Adicionado

- `update.sh` para atualizar o repositório e reaplicar as configs.
- `uninstall.sh` para remover os links do stow com segurança.
- `Makefile` com atalhos `install`, `update`, `doctor`, `lint`, `test` e `uninstall`.
- Flags no bootstrap: `--dry-run`, `--minimal`, `--no-bluetooth` e `--no-aur`.
- `--set CHAVE=VALOR` e `--reset` no menu de controle.
- Validação de Lua no CI e teste de geração de estado em `HOME` temporário.
- Templates de issue/PR, Dependabot, `.gitattributes` e `CHANGELOG.md`.

### Corrigido

- O menu de wallpaper não fecha mais o menu de controle inteiro.
- Opções do menu mostram o valor atual e ações destrutivas pedem confirmação.
- `save()` escapa caracteres especiais ao gravar o `settings.local.env`.
- Backup de conflitos do stow reconhece o formato novo de aviso.
- Hook `pre-commit` é ativado automaticamente via `core.hooksPath`.
- Bootstrap detecta Hyprland anterior ao 0.55 e avisa.

## [2026-11-09]

- Base do Quickshell, estilos por manifesto e melhorias de UX.
- Menu de controle, wallpaper picker, temas dinâmicos com Matugen, `doctor.sh` e documentação.
