#!/bin/bash

# Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Endast root får köra detta script."
    exit 1
fi

# Kontrollera att minst ett användarnamn skickats in
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 ..."
    exit 1
fi

# Första passet: skapa användare och kataloger
for username in "$@"; do
    useradd -m "$username"

    home_dir="/home/$username"

    mkdir -p "$home_dir/Documents"
    mkdir -p "$home_dir/Downloads"
    mkdir -p "$home_dir/Work"

    chown "$username:$username" "$home_dir/Documents"
    chown "$username:$username" "$home_dir/Downloads"
    chown "$username:$username" "$home_dir/Work"

    chmod 700 "$home_dir/Documents"
    chmod 700 "$home_dir/Downloads"
    chmod 700 "$home_dir/Work"
done

# Andra passet: skapa welcome.txt
for username in "$@"; do
    home_dir="/home/$username"
    welcome_file="$home_dir/welcome.txt"

    echo "Välkommen $username" > "$welcome_file"

    getent passwd | cut -d: -f1 | while read -r user; do
        if [ "$user" != "$username" ]; then
            echo "$user" >> "$welcome_file"
        fi
    done

    chown "$username:$username" "$welcome_file"
    chmod 600 "$welcome_file"
done

echo "Klart."
