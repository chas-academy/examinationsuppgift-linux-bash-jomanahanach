#!/bin/bash

# Script to create users, home folders, private subfolders,
# and a welcome file for each user.

# Check that the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Endast root får köra detta script."
    exit 1
fi

# Check that at least one username is provided
if [ $# -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 användare3"
    exit 1
fi

# Loop through all usernames passed as arguments
for USERNAME in "$@"; do

    # Skip if user already exists
    if id "$USERNAME" &>/dev/null; then
        echo "Användaren $USERNAME finns redan. Hoppar över."
        continue
    fi

    # Create user with home directory and private group
    useradd --badname -m -U "$USERNAME"

    # Check if user creation succeeded
    if [ $? -ne 0 ]; then
        echo "Fel: Kunde inte skapa användaren $USERNAME."
        continue
    fi

    # Get the actual home directory from the system
    HOMEDIR=$(getent passwd "$USERNAME" | cut -d: -f6)

    # Create required folders
    mkdir -p "$HOMEDIR/Documents" "$HOMEDIR/Downloads" "$HOMEDIR/Work"

    # Set ownership
    chown "$USERNAME:$USERNAME" "$HOMEDIR/Documents" "$HOMEDIR/Downloads" "$HOMEDIR/Work"

    # Set permissions so only owner can access folders
    chmod 700 "$HOMEDIR/Documents" "$HOMEDIR/Downloads" "$HOMEDIR/Work"

    # Create welcome file
    {
        echo "Välkommen $USERNAME"
        cut -d: -f1 /etc/passwd | grep -v "^$USERNAME$"
    } > "$HOMEDIR/welcome.txt"

    # Set ownership and permissions for welcome file
    chown "$USERNAME:$USERNAME" "$HOMEDIR/welcome.txt"
    chmod 600 "$HOMEDIR/welcome.txt"

    echo "Användaren $USERNAME har skapats."
done
    chown "$USERNAME:$USERNAME" "$HOMEDIR/welcome.txt"
    chmod 600 "$HOMEDIR/welcome.txt"

    echo "Användaren $USERNAME har skapats."
done
