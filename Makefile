SHELL := /bin/bash
SCRIPTS := bootstrap.sh install.sh update.sh uninstall.sh dotsave hooks/pre-commit rice/.config/hypr/scripts/*.sh rice/.config/shell/rice.sh
PYTHON := rice/.config/rice/scripts/style-render.py
LUA := rice/.config/hypr/hyprland.lua

.PHONY: help install dry-run update doctor uninstall lint test

help:
	@printf '%s\n' \
	  'make install     instala o rice (Arch e derivados)' \
	  'make dry-run     mostra o que o bootstrap faria' \
	  'make update      atualiza o repo e reaplica as configs' \
	  'make doctor      diagnóstico do ambiente' \
	  'make lint        bash -n + shellcheck + python/lua' \
	  'make test        lint + gera o estado em um HOME temporário' \
	  'make uninstall   remove os links criados pelo stow'

install:
	./install.sh

dry-run:
	./bootstrap.sh --dry-run

update:
	./update.sh

doctor:
	./doctor.sh

uninstall:
	./uninstall.sh

lint:
	@set -e; for f in $(SCRIPTS); do echo "bash -n $$f"; bash -n "$$f"; done
	@if command -v shellcheck >/dev/null 2>&1; then \
	  shellcheck -S warning $(SCRIPTS); \
	else \
	  echo "shellcheck não encontrado (pulei)"; \
	fi
	@python3 -m py_compile $(PYTHON)
	@if command -v luac >/dev/null 2>&1; then luac -p $(LUA); else echo "luac não encontrado (pulei o Lua)"; fi

test: lint
	@tmp=$$(mktemp -d); trap 'rm -rf "$$tmp"' EXIT; \
	  export HOME="$$tmp"; \
	  stow --no-folding --target="$$tmp" rice; \
	  "$$tmp/.config/hypr/scripts/menu.sh" --init; \
	  if command -v luac >/dev/null 2>&1; then \
	    luac -p "$$tmp/.config/hypr/settings.lua" "$$tmp/.config/hypr/binds.lua"; \
	  fi; \
	  echo "estado gerado em $$tmp (removido no final)"
