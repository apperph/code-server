#!/bin/bash
START_PORT=8080
TOTAL_USERS=30
# CHANGE THIS PASSWORD for your users
COMMON_PASSWORD="DevPassword2026!" 

for i in $(seq 1 $TOTAL_USERS); do
    USERNAME="user$i"
    echo "Enabling $USERNAME ..."
    PORT=$((START_PORT + i))
    sudo systemctl enable --now code-server@$USERNAME
done
