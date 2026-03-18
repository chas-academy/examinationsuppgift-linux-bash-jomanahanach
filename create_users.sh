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
    # Save list of existing users before creating this user
    EXISTING_USERS=$(cut -d: -f1 /etc/passwd)

    # Create group if it does not already exist
    if ! getent group "$USERNAME" >/dev/null 2>&1; then
        groupadd "$USERNAME"
    fi

    # Create user if it does not already exist
    if ! id "$USERNAME" >/dev/null 2>&1; then
        useradd --badname -m -g "$USERNAME" "$USERNAME"
    fi

    # Check if user exists now
    if ! id "$USERNAME" >/dev/null 2>&1; then
        echo "Fel: Kunde inte skapa användaren $USERNAME."
        continue
    fi

    # Get the user's home directory from the system
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
        echo "$EXISTING_USERS" | grep -v "^$USERNAME$"
    } > "$HOMEDIR/welcome.txt"

    # Set ownership and permissions for welcome file
    chown "$USERNAME:$USERNAME" "$HOMEDIR/welcome.txt"
    chmod 600 "$HOMEDIR/welcome.txt"

    echo "Användaren $USERNAME har skapats."
done
