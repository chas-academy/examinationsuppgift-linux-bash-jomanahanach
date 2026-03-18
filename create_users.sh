#!/bin/bash

# Script to create users, home folders, private subfolders,
# and a welcome file for each user.

# Check that the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Endast root får köra detta script."
    exit 1
fi

# Check that at least one username is provided
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 användare3"
    exit 1
fi

# First pass: create users and folders
for username in "$@"; do
    useradd -m "$username"

    home_dir="/home/$username"

    mkdir -p "$home_dir/Documents"
    mkdir -p "$home_dir/Downloads"
    mkdir -p "$home_dir/Work"

    chown -R "$username:$username" "$home_dir"

    chmod 700 "$home_dir/Documents"
    chmod 700 "$home_dir/Downloads"
    chmod 700 "$home_dir/Work"
done

# Second pass: create welcome.txt
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
