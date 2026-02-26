# Central Theme Definitions for watch_theme.sh

# Catppuccin Base Palette (Frappe)
FRA_BASE="#303446"
FRA_SURFACE0="#414559"
FRA_SURFACE1="#51576d"
FRA_OVERLAY0="#737994"
FRA_LAVENDER="#babbf1"
FRA_SAPPHIRE="#85c1dc"
FRA_MAUVE="#ca9ee6"
FRA_RED="#e78284"
FRA_PEACH="#ef9f76"
FRA_TEAL="#81c8be"
FRA_TEXT="#c6d0f5"

# Catppuccin Base Palette (Latte)
LAT_BASE="#eff1f5"
LAT_SURFACE0="#ccd0da"
LAT_SURFACE1="#bcc0cc"
LAT_OVERLAY0="#9ca0b0"
LAT_LAVENDER="#7287fd"
LAT_SAPPHIRE="#209fb5"
LAT_MAUVE="#8839ef"
LAT_RED="#d20f39"
LAT_PEACH="#fe640b"
LAT_TEAL="#179299"
LAT_TEXT="#4c4f69"

# Gemini CLI Themes
GEMINI_THEME_DARK="Default"
GEMINI_THEME_LIGHT="Default Light"

# Bat Themes
BAT_THEME_DARK="Catppuccin Frappe"
BAT_THEME_LIGHT="Catppuccin Latte"

# Vivid (LS_COLORS) Themes
VIVID_THEME_DARK="catppuccin-frappe"
VIVID_THEME_LIGHT="catppuccin-latte"

# Delta Themes
DELTA_THEME_DARK="catppuccin-frappe"
DELTA_THEME_LIGHT="catppuccin-latte"

# Starship Palettes
STARSHIP_PALETTE_DARK="catppuccin_frappe"
STARSHIP_PALETTE_LIGHT="catppuccin_latte"

# Tmux Flavors
TMUX_FLAVOR_DARK="frappe"
TMUX_FLAVOR_LIGHT="latte"

# Zsh / FZF Colors - Dark (Frappe)
ZSH_FZF_COLORS_DARK="--color=bg+:$FRA_SURFACE0,bg:$FRA_BASE,spinner:$FRA_PEACH,hl:$FRA_RED \
--color=fg:$FRA_TEXT,header:$FRA_RED,info:$FRA_MAUVE,pointer:$FRA_PEACH \
--color=marker:$FRA_PEACH,fg+:$FRA_TEXT,prompt:$FRA_MAUVE,hl+:$FRA_RED"
ZSH_AUTOSUGGEST_DARK="fg=$FRA_OVERLAY0"

# Zsh / FZF Colors - Light (Latte)
ZSH_FZF_COLORS_LIGHT="--color=bg+:$LAT_SURFACE0,bg:$LAT_BASE,spinner:$LAT_PEACH,hl:$LAT_RED \
--color=fg:$LAT_TEXT,header:$LAT_RED,info:$LAT_MAUVE,pointer:$LAT_PEACH \
--color=marker:$LAT_PEACH,fg+:$LAT_TEXT,prompt:$LAT_MAUVE,hl+:$LAT_RED"
ZSH_AUTOSUGGEST_LIGHT="fg=$LAT_OVERLAY0"
