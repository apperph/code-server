#!/bin/bash
START_PORT=8080
TOTAL_USERS=30
# CHANGE THIS PASSWORD for your users
COMMON_PASSWORD="DevPassword2026!" 

for i in $(seq 1 $TOTAL_USERS); do
    USERNAME="user$i"
    PORT=$((START_PORT + i))
    
    # Create user
    sudo useradd -m -s /bin/bash $USERNAME
    echo "$USERNAME:$COMMON_PASSWORD" | sudo chpasswd

    # Configure code-server for this specific user
    sudo mkdir -p /home/$USERNAME/.config/code-server
    cat <<EOF | sudo tee /home/$USERNAME/.config/code-server/config.yaml
bind-addr: 127.0.0.1:$PORT
auth: password
password: $COMMON_PASSWORD
cert: false
EOF

    # Set permissions and start the service
    sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.config
    sudo systemctl enable --now code-server@$USERNAME
done
