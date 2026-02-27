#!/usr/bin/env bash
# =========================================================
# Adaptive CachyOS Fish Installer (optional productivity pack)
# Installs addabbr + optional productivity pack
# =========================================================

set -e

echo "🚀 Installing ultra-powerful fish addabbr..."

# ------------------------------
# 1️⃣ Detect fish config directory
# ------------------------------
if test -n "$XDG_CONFIG_HOME"; then
    FISH_CONFIG_DIR="$XDG_CONFIG_HOME/fish"
else
    FISH_CONFIG_DIR="$HOME/.config/fish"
fi

mkdir -p "$FISH_CONFIG_DIR/functions"
echo "Detected fish config dir: $FISH_CONFIG_DIR"

# ------------------------------
# 2️⃣ Install addabbr function
# ------------------------------
cat > "$FISH_CONFIG_DIR/functions/addabbr.fish" <<'EOF'
function addabbr
    if test (count $argv) -ne 1
        echo "Usage: addabbr <shortcut>"
        return 1
    end
    set shortcut $argv[1]

    set last_history (history | head -n 1)
    if test -z "$last_history"
        echo "No previous command found."
        return 1
    end

    set last_cmd (string replace -r '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} ' '' $last_history)
    set escaped (string escape -- $last_cmd)

    set file "$FISH_CONFIG_DIR/cachyos-productivity.fish"

    if not test -f $file
        echo "# CachyOS Productivity Abbreviations" | tee -a $file >/dev/null
    end

    set existing (grep -E "^abbr.*--position command $shortcut --" $file)
    if test -n "$existing"
        echo "Shortcut '$shortcut' exists:"
        echo "  $existing"
        read -P "Overwrite? (y/N) " confirm
        if test "$confirm" != "y" -a "$confirm" != "Y"
            echo "Aborting."
            return 0
        end
        sed -i "/^abbr.*--position command $shortcut --/d" $file
    end

    set timestamp (date "+%Y-%m-%d %H:%M:%S")
    echo "# Added by addabbr on $timestamp" | tee -a $file >/dev/null
    echo "abbr --add --position command $shortcut -- $escaped" | tee -a $file >/dev/null

    source $file
    echo "✅ Added abbr '$shortcut' -> '$last_cmd' and reloaded!"
end
EOF

# Make persistent
fish -c "funcsave addabbr"
echo "✅ addabbr installed!"

# ------------------------------
# 3️⃣ Ask user about productivity pack
# ------------------------------
read -p "Do you want to install the full CachyOS productivity pack? [y/N]: " install_pack
if [[ "$install_pack" != "y" && "$install_pack" != "Y" ]]; then
    echo "Skipping productivity pack installation."
    exit 0
fi

echo "Installing productivity pack..."

PRODUCTIVITY_FILE="$FISH_CONFIG_DIR/cachyos-productivity.fish"
touch "$PRODUCTIVITY_FILE"

# Base pack
cat > "$PRODUCTIVITY_FILE" <<'EOF'
# =================================
# CachyOS Base Productivity Abbreviations
# =================================

abbr --add --position command ls -- "eza -al --color=always --group-directories-first --icons"
abbr --add --position command la -- "eza -a --color=always --group-directories-first --icons"
abbr --add --position command ll -- "eza -l --color=always --group-directories-first --icons"
abbr --add --position command lt -- "eza -aT --color=always --group-directories-first --icons"
abbr --add --position command l. -- "eza -a | grep -e '^\.'"

abbr --add --position command .. -- "cd .."
abbr --add --position command ... -- "cd ../.."
abbr --add --position command .... -- "cd ../../.."
abbr --add --position command ..... -- "cd ../../../.."

abbr --add --position command psmem -- "ps auxf | sort -nr -k 4"
abbr --add --position command psmem10 -- "ps auxf | sort -nr -k 4 | head -10"

abbr --add --position command update -- "sudo pacman -Syu"
abbr --add --position command please -- "sudo"
abbr --add --position command jctl -- "journalctl -p 3 -xb"
EOF

# Optional commands if installed
command -v docker >/dev/null 2>&1 && cat >> "$PRODUCTIVITY_FILE" <<'EOF'
abbr --add --position command dps -- "docker ps"
abbr --add --position command di -- "docker images"
EOF

command -v kubectl >/dev/null 2>&1 && cat >> "$PRODUCTIVITY_FILE" <<'EOF'
abbr --add --position command kgetpods -- "kubectl get pods -A"
abbr --add --position command kgetnodes -- "kubectl get nodes"
EOF

command -v yay >/dev/null 2>&1 && cat >> "$PRODUCTIVITY_FILE" <<'EOF'
abbr --add --position command yup -- "yay -Syu"
abbr --add --position command ysearch -- "yay -Ss"
EOF

# Ensure config loads productivity file
MAIN_CONFIG="$FISH_CONFIG_DIR/config.fish"
grep -qxF "source $PRODUCTIVITY_FILE" "$MAIN_CONFIG" || echo "source $PRODUCTIVITY_FILE" >> "$MAIN_CONFIG"

# Reload
fish -c "source $PRODUCTIVITY_FILE"

echo "✅ Productivity pack installed!"
echo "All abbreviations and 'addabbr' are ready to use."
