function addabbr
    # ===================================
    # Fish-only ultra-powerful addabbr
    # Uses previous command safely (strips timestamps)
    # Detects duplicates precisely
    # Escapes special chars
    # ===================================

    if test (count $argv) -ne 1
        echo "Usage: addabbr <shortcut>"
        return 1
    end

    set shortcut $argv[1]

    # Get last command from history (fish timestamps: YYYY-MM-DD HH:MM:SS ...)
    set last_history (history | head -n 1)

    if test -z "$last_history"
        echo "No previous command found."
        return 1
    end

    # Remove leading timestamp if it exists
    # Match 4-digit year, then dash, then MM-DD HH:MM:SS followed by space
    set last_cmd (string replace -r '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} ' '' $last_history)

    # Escape quotes and backslashes for safe insertion
    set escaped (string escape -- $last_cmd)

    # Config file
    set file /usr/share/cachyos-fish-config/cachyos-config.fish

    # Ensure file exists
    if not test -f $file
        echo "# CachyOS Abbreviations Config" | sudo tee -a $file >/dev/null
    end

    # Check for existing shortcut (exact match)
    set existing (grep -E "^abbr.*--position command $shortcut --" $file)
    if test -n "$existing"
        echo "Shortcut '$shortcut' already exists:"
        echo "  $existing"
        read -P "Overwrite? (y/N) " confirm
        if test "$confirm" != "y" -a "$confirm" != "Y"
            echo "Aborting."
            return 0
        end
        sudo sed -i "/^abbr.*--position command $shortcut --/d" $file
    end

    # Timestamp comment for tracking
    set timestamp (date "+%Y-%m-%d %H:%M:%S")
    echo "# Added by addabbr on $timestamp" | sudo tee -a $file >/dev/null

    # Append the new abbr line
    echo "abbr --add --position command $shortcut -- $escaped" | sudo tee -a $file >/dev/null

    # Reload config immediately
    source $file

    echo "✅ Added abbr '$shortcut' -> '$last_cmd' and reloaded!"
end
