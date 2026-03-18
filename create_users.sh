#!/bin/bash
# create_users.sh
# Skapar användare med hemkataloger, undermappar och välkomstfil.
# Användning: ./create_users.sh Anna Bjorn Charlie

# Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Du måste vara root för att köra detta script." >&2
    exit 1
fi

# Kontrollera att minst ett användarnamn skickades in
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 <användare1> [användare2] ..." >&2
    exit 1
fi

# Första passet: skapa användare
for username in "$@"; do
    if ! id "$username" >/dev/null 2>&1; then
        useradd -m "$username"
    fi
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

echo "Klart! Alla angivna användare har behandlats."
exit 0
