#!/bin/bash

# Script som skapar användare, hemkataloger, undermappar
# och en personlig welcome.txt för varje användare.

# Kontrollera att scriptet körs som root.
# Om användaren har sudo-rättigheter körs scriptet om med sudo.
if [ "$EUID" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
        exec sudo "$0" "$@"
    else
        echo "Fel: Endast root får köra detta script."
        exit 1
    fi
fi

# Kontrollera att minst ett användarnamn skickats in
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 användare3"
    exit 1
fi

# Första passet: skapa användare med hemkatalog och grupp
for username in "$@"; do
    useradd -m -U "$username"
done

# Andra passet: skapa mappar, rättigheter och welcome.txt
for username in "$@"; do
    home_dir="/home/$username"
    welcome_file="$home_dir/welcome.txt"

    mkdir -p "$home_dir/Documents"
    mkdir -p "$home_dir/Downloads"
    mkdir -p "$home_dir/Work"

    chown -R "$username:$username" "$home_dir"

    chmod 700 "$home_dir/Documents"
    chmod 700 "$home_dir/Downloads"
    chmod 700 "$home_dir/Work"

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
