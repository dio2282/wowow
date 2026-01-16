#!/bin/bash
# Huly Complete Nginx - team.kalwi.dev → 16461 + SSL phoenixnodes
# Run di ~/huly-selfhost

DOMAIN="team.kalwi.dev"
MAIN_PORT="16461"  # Huly front utama (phoenixnodes proxy)

echo "🚀 Huly Nginx Multi-Path Fix (16461 main)"

# Huly config
sed -i.bak "s/HOST_ADDRESS=.*/HOST_ADDRESS=$DOMAIN/" huly_v7.conf
sed -i.bak "s/SECURE=.*/SECURE=true/" huly_v7.conf  # SSL via phoenixnodes
./nginx.sh

# Complete nginx.conf - ALL Huly paths
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name team.kalwi.dev;
        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name team.kalwi.dev;

        # SSL dari phoenixnodes proxy.sh
        ssl_certificate /etc/letsencrypt/live/team.kalwi.dev/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/team.kalwi.dev/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;

        client_max_body_size 100M;

        # HULY FRONT - MAIN PORT 16461
        location / {
            proxy_pass http://127.0.0.1:16461/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_read_timeout 86400;
        }

        # CRITICAL HULY SERVICES
        location /_transactor/ {
            rewrite ^/_transactor/(.*) /$1 break;
            proxy_pass http://transactor:3001/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_read_timeout 86400;
        }

        location /_accounts/ {
            proxy_pass http://account:3000/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /_account/ {
            proxy_pass http://account:3000/;
            proxy_http_version 1.1
