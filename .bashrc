# Bash Config
# Detect if running as root
if [[ $EUID -eq 0 ]]; then
    # Root configuration
    PROMPT_COLOR='\[\033[38;5;1m\]'      # Red for root
    USER_INDICATOR='root '
    LOCAL_SCRIPTS_PATH="/root/.local/scripts"
    LOGO_PATH="/root/debianroot.png"
    LOGO_PADDING_LEFT=4
    LOGO_PADDING_TOP=2
    TITLE_COLOR_USER=31
    
else
    # Regular user configuration  
    PROMPT_COLOR='\[\033[38;5;49m\]'     # Green for user
    USER_INDICATOR=''
    LOCAL_SCRIPTS_PATH="$HOME/.local/scripts"
    LOGO_PATH="$HOME/Pictures/Logos/debian.png"
    LOGO_PADDING_LEFT=4
    LOGO_PADDING_TOP=2
    TITLE_COLOR_USER=36
    
fi

# Prompt - bash equivalent of your zsh prompts
PS1=' \[\033[38;5;240m\]\w ${PROMPT_COLOR}${USER_INDICATOR}\[\033[38;5;49m\]>\[\033[0m\] '

# Path configuration
if [[ $EUID -eq 0 ]]; then
    # Root: only add local scripts (no .local/bin since root doesn't typically use it)
    export PATH="$LOCAL_SCRIPTS_PATH:$PATH"
else
    # User: add both local scripts and local bin
    export PATH="$LOCAL_SCRIPTS_PATH:$PATH"
fi

# Environment variables (NixOS compatible)
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export EDITOR="vim"
export VISUAL="vim"
export GTK_THEME=Tokyonight-Dark
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland

# Common aliases
alias ps='ps aux'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'
alias ll='ls -al'

# User-specific functions (only for regular user, not root)
if [[ $EUID -ne 0 ]]; then
    # Configuration management
    update_bash() {
        echo "Updating both user and root .bashrc files..."
        sudo cp ~/.bashrc /root/.bashrc
        echo "✓ Both configs updated"
        echo "Note: Changes will take effect on next shell session or after 'source ~/.bashrc'"
    }

    # Shell Commands
    ii() {
        eog "$@" > /dev/null 2>&1 &
    }

    # Services Monitor
    service_status() {
        echo "=== FAILED SERVICES (Critical!) ==="
        systemctl list-units --type=service --state=failed --no-pager
        echo -e "\n=== RUNNING SERVICES ==="
        systemctl list-units --type=service --state=running --no-pager
        echo -e "\n=== EXITED SERVICES (One-shot completed) ==="
        systemctl list-units --type=service --state=exited --no-pager
        echo -e "\n=== INACTIVE SERVICES ==="
        systemctl list-units --type=service --state=inactive --no-pager
        echo "... (showing first 10 inactive services)"
    }

    # NixOS-specific functions
    nixos_generations() {
        echo "=== NixOS System Generations ==="
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
    }

    nixos_cleanup() {
        echo "=== NixOS Cleanup ==="
        echo "Removing old generations (keeping last 3)..."
        sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system
        echo "Running garbage collection..."
        sudo nix-collect-garbage -d
        echo "Optimizing nix store..."
        sudo nix-store --optimise
        echo "✓ Cleanup complete"
    }

    nixos_size() {
        echo "=== NixOS Store Size ==="
        du -sh /nix/store 2>/dev/null || echo "Cannot access /nix/store"
        echo ""
        echo "=== Generation Sizes ==="
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | \
        while read -r gen _; do
            if [[ "$gen" =~ ^[0-9]+$ ]]; then
                size=$(du -sh /nix/var/nix/profiles/system-"$gen"-link 2>/dev/null | cut -f1)
                printf "  Generation %-3s: %s\n" "$gen" "$size"
            fi
        done
    }

    nixos_switch_test() {
        if [ -z "$1" ]; then
            echo "Usage: nixos_switch_test <description>"
            echo "Example: nixos_switch_test \"Added new packages\""
            return 1
        fi
        echo "Testing configuration: $1"
        sudo nixos-rebuild test && \
        echo "✓ Test successful. Run 'nrs' to make permanent or reboot to revert."
    }
fi

# History configuration (bash syntax)
HISTFILE=~/.bash_history
HISTSIZE=10000
HISTFILESIZE=10000
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Display configuration and fastfetch
fbset -g 2880 1800 2880 1800 32
clear

if [[ -n "$DISPLAY" || "$XDG_SESSION_TYPE" == "wayland" ]]; then
    # In GUI terminal
    if [[ $EUID -eq 0 ]]; then
        # Root fastfetch
        fastfetch --logo-type none \
                  --title-color-user $TITLE_COLOR_USER
    else
        # User fastfetch
        fastfetch --logo-type sixel \
                  --logo "$LOGO_PATH" \
                  --logo-height 12 \
                  --logo-width 22 \
                  --logo-padding-left $LOGO_PADDING_LEFT \
                  --logo-padding-top $LOGO_PADDING_TOP \
                  --title-color-user $TITLE_COLOR_USER \
                  --color-keys magenta \
                  --title-color-host magenta
    fi
else
    # In TTY
    if [[ $EUID -eq 0 ]]; then
        # Root TTY
        fastfetch --logo-type none \
                  --color-keys magenta \
                  --title-color-user 36 \
                  --title-color-host magenta
    else
        # User TTY  
        fastfetch --logo-type none \
                  --title-color-user 36
    fi
fi
