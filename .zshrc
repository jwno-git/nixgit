# ZSH Config File
PROMPT='%F{240}%/ %F{49}>%f '

# Path
export PATH="$HOME/.local/scripts:$PATH"
export EDITOR="vim"
export VISUAL="vim"
export GTK_THEME=Tokyonight-Dark
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland

# Aliases
alias ff="fastfetch --logo-type sixel --logo "/$HOME/Pictures/Logos/nixoslogo.png" --logo-padding-top 3 --logo-padding-left 1 --logo-padding-right 3 --color-keys magenta --title-color-user 36 --title-color-host magenta"
alias hyp="Hyprland"

# Plugins
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-completions/zsh-completions.zsh

fpath=(~/.zsh/zsh-completions/src $fpath)

fbset -g 2880 1800 2880 1800 32
clear
if [[ -n "$DISPLAY" || "$XDG_SESSION_TYPE" == "wayland" ]]; then
  # In GUI terminal
  fastfetch --logo-type sixel --logo "/$HOME/Pictures/Logos/nixoslogo.png" --logo-padding-top 2 --logo-padding-left 2 --color-keys magenta --title-color-user 36 --title-color-host magenta
else
  # In TTY
  fastfetch --logo-type none --color-keys magenta --title-color-user 36 --title-color-host magenta
fi
