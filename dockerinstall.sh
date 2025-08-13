#!/usr/bin/env bash
# script.sh - install Docker, Compose, git, etc., then clone and run the app

set -euo pipefail

echo "################################################################################################"
echo "################################################################################################"
echo "################################################################################################"
echo "==> Step 1: apt update"
sudo apt update

echo "==> Step 2: upgrade packages (-y)"
sudo apt-get upgrade -y

echo "==> Step 3: install git"
sudo apt install -y git

echo "==> Step 4: install unzip"
sudo apt install -y unzip

echo "==> Step 5: install curl"
sudo apt install -y curl

echo "==> Step 6: download Docker installer (test.docker.com)"
curl -fsSL https://test.docker.com -o test-docker.sh

echo "==> Step 7: run Docker installer script"
sudo sh test-docker.sh

echo "==> Step 8: ensure 'docker' group exists"
sudo groupadd docker 2>/dev/null || echo "    'docker' group already exists"

echo "==> Step 9: add current user to 'docker' group"
sudo usermod -aG docker "$USER" || true
echo "    NOTE: you must log out/in (or run 'newgrp docker') for group changes to take effect."

echo "==> Step 10: (optional) refresh group in current shell (skipped in script)"
echo "    If you want to refresh now run manually: newgrp docker"

echo "==> Step 11: enable docker.service"
sudo systemctl enable docker.service

echo "==> Step 12: enable containerd.service"
sudo systemctl enable containerd.service

echo "==> Step 13: apt-get update (post-Docker repo setup)"
sudo apt-get update -y

echo "==> Step 14: install docker-compose plugin"
sudo apt-get install -y docker-compose-plugin

echo "==> Step 15: show Docker Compose version"
sudo docker compose version || true
echo "################################################################################################"
echo "################################################################################################"
echo "################################################################################################"
echo "✅ All done."
