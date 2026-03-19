#!/bin/bash

# --- Parameter Handling ---
TOTAL_USERS=${1:?Usage: $0 <total_users> [start_port]}
START_PORT=${2:-8080}

# --- Generate Secure Random Password (16 chars) ---
COMMON_PASSWORD=$(openssl rand -base64 18 | tr -dc 'A-Za-z0-9!@#$%^&*()_+=' | head -c 16)

echo "========================================"
echo "Common password for all users:"
echo "$COMMON_PASSWORD"
echo "========================================"

# --- User Loop ---
for i in $(seq 1 "$TOTAL_USERS"); do
    USERNAME="user$i"
    PORT=$((START_PORT + i))

    echo "Enabling $USERNAME on port $PORT ..."
    
    # Enable service
    sudo systemctl enable --now "code-server@$USERNAME"

    # (Optional placeholder if you later want to assign password automatically)
    echo "$USERNAME:$COMMON_PASSWORD" | sudo chpasswd
done

