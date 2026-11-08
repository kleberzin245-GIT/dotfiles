# Atalhos

`SUPER` é a tecla Windows.

## Atalhos editáveis

Estes são os padrões. Você pode trocar qualquer um deles em **`SUPER+M` → Atalhos**: escolha o atalho, depois os modificadores e a tecla numa lista. O menu avisa se a combinação já estiver em uso.

| Atalho | Ação |
|---|---|
| `SUPER + RETURN` | Abrir terminal |
| `SUPER + D` | Abrir launcher |
| `SUPER + Q` | Fechar janela |
| `SUPER + SHIFT + E` | Sair do Hyprland |
| `SUPER + F` | Tela cheia |
| `SUPER + V` | Alternar janela flutuante |
| `SUPER + P` | Pseudo-tile |
| `SUPER + J` | Alternar divisão |
| `SUPER + L` | Bloquear a tela |
| `SUPER + W` | Wallpaper aleatório |
| `SUPER + SHIFT + W` | Escolher wallpaper (grade de miniaturas) |
| `SUPER + C` | Histórico da área de transferência |
| `SUPER + M` | Menu de controle |
| `Print` | Captura de tela (seleção de área) |

## Atalhos fixos

| Atalho | Ação |
|---|---|
| `SUPER + setas` | Mover o foco entre janelas |
| `SUPER + 1 … 0` | Ir para o workspace |
| `SUPER + SHIFT + 1 … 0` | Mover a janela para o workspace |
| `SUPER + scroll` | Trocar de workspace |
| `SUPER + botão esquerdo` (arrastar) | Mover janela |
| `SUPER + botão direito` (arrastar) | Redimensionar janela |
| Teclas de volume e brilho | Ajustam volume e brilho |
| Teclas de mídia | Play/pausa, próxima, anterior |

## Onde ficam

- `rice/.config/hypr/binds.tsv` — a lista editável (versionada no git).
- `~/.config/hypr/binds.lua` — gerado a partir do `.tsv` (não versionado, não edite à mão).
- `rice/.config/hypr/hyprland.lua` — os atalhos fixos.

Para restaurar os padrões: `SUPER+M` → Atalhos → "Restaurar atalhos padrão".
