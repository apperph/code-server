#!/bin/bash

# 1. Create the base configuration for Infrastructure
cat <<EOF > docker-compose.yml
version: '3.8'

networks:
  lab-net:
    driver: bridge

services:
  # Nginx Proxy Manager
  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: npm
    restart: always
    ports:
      - "80:80"
      - "81:81"
      - "443:443"
    volumes:
      - ./data/npm:/data
      - ./data/letsencrypt:/etc/letsencrypt
    networks:
      - lab-net

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--web.console.libraries=/usr/share/prometheus/console_libraries"
      - "--web.console.templates=/usr/share/prometheus/consoles"
      - "--web.external-url=https://vscode.apperlabs.com/prometheus/"
    volumes:
      - ./data/prometheus:/etc/prometheus
    networks:
      - lab-net

  # Grafana
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_SERVER_ROOT_URL=https://vscode.apperlabs.com/grafana/
      - GF_SERVER_SERVE_FROM_SUB_PATH=true
    networks:
      - lab-net
EOF

# 2. Loop to append 5 Users
numberOfUsers=5
for i in $(seq 1 $numberOfUsers); do
  
  cat <<EOF >> docker-compose.yml

  user${i}:
    image: codercom/code-server:latest
    container_name: user${i}
    environment:
      - PASSWORD=labuser${i}
    networks:
      - lab-net
    deploy:
      resources:
        limits:
          cpus: '1.5'
          memory: 2G
    volumes:
      - ./data/user${i}:/home/coder/project
EOF
done

echo "docker-compose.yml generated for ${numberOfUsers} users!"
