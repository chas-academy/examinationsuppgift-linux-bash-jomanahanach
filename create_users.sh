#!/bin/bash

# This script creates users, their home folders,
# private subfolders, and a welcome file.

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Endast root får köra detta script."
    exit 1
fi

# Check if at least one username was provided
if [ $# -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 användare3"
    exit 1
fi

# Loop through all usernames
for USERNAME in "$@"; do
    # Save current users before creating the new one
    OTHER_USERS=$(cut -d: -f1 /etc/passwd)

    # Create the user with home directory
    useradd -m "$USERNAME"

    # Stop this iteration if user creation failed
    if [ $? -ne 0 ]; then
        echo "Fel: Kunde inte skapa användaren $USERNAME."
        continue
    fi

    HOMEDIR="/home/$USERNAME"

    # Create required folders
    mkdir -p "$HOMEDIR/Documents"
    mkdir -p "$HOMEDIR/Downloads"
    mkdir -p "$HOMEDIR/Work"

    # Set ownership
    chown -R "$USERNAME:$USERNAME" "$HOMEDIR"

    # Set folder permissions
    chmod 700 "$HOMEDIR/Documents"
    chmod 700 "$HOMEDIR/Downloads"
    chmod 700 "$HOMEDIR/Work"

    # Create welcome file
    echo "Välkommen $USERNAME" > "$HOMEDIR/welcome.txt"
    echo "$OTHER_USERS" | grep -v "^$USERNAME$" >> "$HOMEDIR/welcome.txt"

    # Set file ownership and permissions
    chown "$USERNAME:$USERNAME" "$HOMEDIR/welcome.txt"
    chmod 600 "$HOMEDIR/welcome.txt"
done
