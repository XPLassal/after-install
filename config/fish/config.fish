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
    alias r 'paru -Rns'

end

function update-mirrors
    echo "🚀 Ищем самые быстрые зеркала..."
    set TMPFILE (mktemp)
    # Ищем зеркала (свежесть 6 часов)
    rate-mirrors --save=$TMPFILE arch --max-delay=21600
    or return 1

    # Применяем
    sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup
    sudo mv $TMPFILE /etc/pacman.d/mirrorlist

    # Обновляем базы и чистим кэш (оставляем 3 версии пакетов)
    echo "📦 Обновляем систему..."
    sudo paccache -rk3
    paru -Syyu --noconfirm
end