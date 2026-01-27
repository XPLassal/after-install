function fish_prompt -d "Write out the prompt"
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive # Commands to run in interactive sessions can go here

    # No greeting
    set fish_greeting

    # Use starship
    starship init fish | source

    # Aliases
    alias pamcan pacman
    alias ls 'eza --icons'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias q 'qs -c ii'
    alias i 'paru -Sy'
    alias in 'paru -Sy --noconfirm'
    alias r 'paru -Rns'
    alias rdd 'paru -Rdd'

end

function update-mirrors
    echo "🚀 [1/2] Официальные зеркала..."
    set TMPFILE (mktemp)
    rate-mirrors --save=$TMPFILE arch --max-delay=21600 || return 1

    sudo mv /etc/pacman.d/mirrorlist{,-backup}
    sudo mv $TMPFILE /etc/pacman.d/mirrorlist

    if test -f /etc/pacman.d/alhp-mirrorlist
        echo "🚀 [2/2] ALHP зеркала..."
        set ALHP_TMP (mktemp)
        
        curl -s https://alhp.GO-BUILD-IT.io/mirrorlist | rate-mirrors --save=$ALHP_TMP stdin

        test -s $ALHP_TMP || return 1

        sudo mv /etc/pacman.d/alhp-mirrorlist{,-backup}
        sudo mv $ALHP_TMP /etc/pacman.d/alhp-mirrorlist
    end

    echo "📦 Обновление..."
    sudo paccache -rk3
    paru -Syyu --noconfirm
end