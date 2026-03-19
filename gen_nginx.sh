#!/bin/bash
echo "server {"
echo "    listen 80;"
echo "    server_name _;"

for i in $(seq 1 30); do
    PORT=$((8080 + i))
    echo "    location /user$i/ {"
    echo "        proxy_pass http://127.0.0.1:$PORT/;"
    echo "        proxy_set_header Host \$host;"
    echo "        proxy_set_header Upgrade \$http_upgrade;"
    echo "        proxy_set_header Connection upgrade;"
    echo "        proxy_set_header Accept-Encoding gzip;"
    echo "    }"
done
echo "}"
