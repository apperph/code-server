#!/bin/bash

# Define users and starting port
START_PORT=9001
USERS=(user31 user32 user33 user34 user35)

echo "Updating code-server configs and restarting services..."

# Loop through each user
for i in "${!USERS[@]}"; do
    USER=${USERS[$i]}
    PORT=$((START_PORT + i))

    echo "Configuring $USER on port $PORT"

    # Create config directory if it doesn't exist
    sudo -u $USER mkdir -p /home/$USER/.config/code-server

    # Write config.yaml
    sudo tee /home/$USER/.config/code-server/config.yaml > /dev/null <<EOF
bind-addr: 0.0.0.0:$PORT
auth: password
password: "DevPassword2026!"
cert: false
EOF

    # Restart the user's code-server service
    sudo systemctl restart code-server@$USER
done

echo
echo "All services restarted."
echo
echo "===== Nginx snippet for users 31-35 ====="
for i in "${!USERS[@]}"; do
    USER=${USERS[$i]}
    PORT=$((START_PORT + i))
    echo ""
    echo "# $USER"
    echo "location = /$USER { return 301 /$USER/; }"
    echo "location /$USER/ { proxy_pass http://127.0.0.1:$PORT/; proxy_set_header Host \$host; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection upgrade; proxy_set_header Accept-Encoding gzip; }"
done
echo
echo "Copy the above snippet into your Nginx config and reload Nginx:"
echo "sudo systemctl reload nginx"
