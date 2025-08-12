#!/usr/bin/env bash
# install-docker-and-compose.sh
# Installs Docker (using test.docker.com script), enables services,
# adds your user to the "docker" group, and installs Docker Compose v2 plugin.

set -euo pipefail

# Pick the target user to add into the 'docker' group:
# - If run via sudo, default to the invoking user ($SUDO_USER)
# - Else default to the current user
# - Allow override via env var: TARGET_USER=jane ./install-docker-and-compose.sh
TARGET_USER="${TARGET_USER:-${SUDO_USER:-$USER}}"

echo "==> Using target user: ${TARGET_USER}"

echo "==> Step 1: Update package lists"
sudo apt update

echo "==> Step 2: Upgrade installed packages"
sudo apt-get upgrade -y

echo "==> Step 3: Download and install Docker using test.docker.com"
# Uses the same source you specified; this installs Docker Engine, CLI, and configures the repo.
curl -fsSL https://test.docker.com -o /tmp/test-docker.sh
sudo sh /tmp/test-docker.sh
rm -f /tmp/test-docker.sh

echo "==> Step 4: Create 'docker' group if needed and add user to it"
if ! getent group docker >/dev/null 2>&1; then
  sudo groupadd docker
fi

# Add the target user to the docker group (safe if already a member)
if id -nG "${TARGET_USER}" | grep -qw docker; then
  echo "    ${TARGET_USER} is already in the 'docker' group."
else
  sudo usermod -aG docker "${TARGET_USER}" || true
  echo "    Added ${TARGET_USER} to 'docker' group."
fi

# newgrp in a script won't persist for the caller's shell; inform instead.
echo "    NOTE: You must log out and log back in (or run 'newgrp docker') for group changes to take effect."

echo "==> Step 5: Enable Docker services to start on boot"
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
# Optionally start them now (harmless if already running)
sudo systemctl start docker.service || true
sudo systemctl start containerd.service || true

echo "==> Step 6: Install Docker Compose (v2 plugin)"
# With Docker’s repo configured by the test script, this installs the official plugin.
sudo apt-get update
sudo apt-get install -y docker-compose-plugin

echo "==> Verifying installations"
docker --version || { echo "Docker not found on PATH (a re-login may be required)"; exit 1; }
# Prefer 'docker compose', fallback to legacy if present
if docker compose version >/dev/null 2>&1; then
  docker compose version
else
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose --version
  else
    echo "Docker Compose plugin not found on PATH yet (try re-logging in)."
  fi
fi

echo "==> All done!"
echo "    Remember to log out and back in so '${TARGET_USER}' can use 'docker' without sudo."
# Optional quick test (uncomment if desired):
# docker run --rm hello-world
