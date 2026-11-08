# Personalização do rice

O menu de controle (`menu.sh`) permite mudar o visual sem tocar em configuração manual.

## O que você pode mudar

| Opção | Efeito |
|---|---|
| **Estilo** | Troca `Padrão`, `Liquid Glass` e `Omarchy` (gaps, arredondamento, borda, blur, transparência, tema do Waybar e Kitty) |
| **Tema** | Altera o modo claro/escuro e a cor base (via Matugen) |
| **Janelas** | Ajusta gaps, arredondamento, borda e opacidade das janelas |
| **Blur** | Liga/desliga e ajusta o blur das janelas |
| **Transparência** | Ajusta a opacidade do Waybar e do Kitty |
| **Gelatina** | Ajusta a animação "gelatina" das animações |
| **Atalhos** | Edita, visualiza ou restaura atalhos |
| **Energia** | Bloquear, suspender, sair, reiniciar ou desligar |

## Como aplicar um estilo

Abra o menu (`SUPER + M`) → **Estilo** → escolha um.

> Os estilos trocam o Waybar, o Kitty, os gaps, o blur e o menu interativo via `apply_style`.

## Tema dinâmico (Matugen)

O Matugen gera as cores automaticamente a partir do wallpaper. Ao mudar de wallpaper, o
tema atualiza sozinho (via `wallpaper.sh` → `matugen image`).
