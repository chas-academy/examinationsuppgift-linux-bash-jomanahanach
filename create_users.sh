#!/bin/bash

# =========================================================
# create_users.sh
# Skapar användare utifrån argument till scriptet.
# För varje användare skapas:
#   - hemkatalog
#   - grupp
#   - mapparna Documents, Downloads och Work
#   - filen welcome.txt
#
# Scriptet får endast köras av root.
# Exempel:
#   ./create_users.sh Anna Bjorn Charlie
# =========================================================

# Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Endast root får köra detta script."
    exit 1
fi

# Kontrollera att minst ett användarnamn har skickats in
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 användare3 ..."
    exit 1
fi

# ---------------------------------------------------------
# Första passet: skapa användare och katalogstruktur
# ---------------------------------------------------------
for username in "$@"; do
    # Hoppa över om användaren redan finns
    if id "$username" >/dev/null 2>&1; then
        echo "Användaren '$username' finns redan. Hoppar över."
        continue
    fi

    # Skapa användare (systemet skapar oftast grupp automatiskt)
    useradd -m -s /bin/bash "$username"

    home_dir="/home/$username"

    # Skapa mappar
    mkdir -p "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"

    # Sätt ägare
    chown -R "$username:$username" "$home_dir"

    # Sätt rättigheter (endast ägare)
    chmod 700 "$home_dir/Documents"
    chmod 700 "$home_dir/Downloads"
    chmod 700 "$home_dir/Work"

    echo "Skapade användare: $username"
done

# ---------------------------------------------------------
# Andra passet: skapa welcome.txt
# ---------------------------------------------------------
for username in "$@"; do
    # Kontrollera att användaren finns
    if ! id "$username" >/dev/null 2>&1; then
        continue
    fi

    home_dir="/home/$username"
    welcome_file="$home_dir/welcome.txt"

    # Första raden (EXAKT enligt krav)
    echo "Välkommen $username" > "$welcome_file"

    # Lista alla andra användare
    getent passwd | cut -d: -f1 | while read -r user; do
        if [ "$user" != "$username" ]; then
            echo "$user" >> "$welcome_file"
        fi
    done

    # Rätt ägare och rättigheter
    chown "$username:$username" "$welcome_file"
    chmod 600 "$welcome_file"
done

echo "Klart."
