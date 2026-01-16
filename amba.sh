#!/bin/bash
# Huly Safe Uninstall - KEEP Nginx/SSL/Dynmap
cd ~/huly-selfhost || exit 1

echo "🛑 Huly Safe Stop & Clean (Nginx aman)"

# 1. Stop containers
sudo docker compose down

# 2. Remove containers (force safe)
sudo docker rm -f $(sudo docker ps -aq --filter "name=huly_v7")

# 3. Remove networks
sudo docker network rm huly_net 2>/dev/null || true

# 4. Remove Huly volumes (KEEP other!)
sudo docker volume ls --format "table {{.Name}}" | grep huly_v7 | xargs -r sudo docker volume rm -f

# 5. Remove Nginx symlink
sudo rm -f /etc/nginx/sites-enabled/huly.conf
sudo nginx -t && sudo nginx -s reload

# 6. Optional: delete folder
# rm -rf ~/huly-selfhost  # UNCOMMENT kalau yakin

echo "✅ Huly DELETED! Nginx/SSL/Dynmap aman."
echo "Cek: docker ps | grep huly (kosong)"
echo "Nginx: curl https://team.kalwi.dev (SSL work)"
