#!/bin/bash

# --- Parameter Handling ---
TOTAL_USERS=${1:?Usage: $0 <total_users> [start_port]}
START_PORT=${2:-8080}

echo "========================================"
echo "Stopping and disabling code-server for $TOTAL_USERS users..."
echo "========================================"

# --- User Loop ---
for i in $(seq 1 "$TOTAL_USERS"); do
    USERNAME="user$i"
    PORT=$((START_PORT + i))

    echo "Disabling $USERNAME (port $PORT) ..."

    # Stop and disable service
    sudo systemctl disable --now "code-server@$USERNAME"
done

echo "========================================"
echo "All services stopped and disabled."
echo "========================================"

