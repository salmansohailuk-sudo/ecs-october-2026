#!/usr/bin/env bash
set -Eeuo pipefail

# Builder EC2 setup for Amazon Linux 2023.
# Run with: sudo ./pack.sh

LOG_FILE="/var/log/setup-builder-ec2.log"
REPO_URL="https://github.com/salmansohailuk-sudo/ecs-october-2026.git"
REPO_DIR="/home/ec2-user/ecs-october-2026"
COMPOSE_VERSION="v2.29.2"
COMPOSE_PLUGIN_DIR="/usr/local/lib/docker/cli-plugins"

# Check privileges before trying to create/write the root-owned log file.
if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Run this script as root: sudo $0" >&2
  exit 1
fi

# Send output to both the terminal and a log file.
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
chmod 0644 "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

trap 'rc=$?; echo "ERROR: Setup failed (exit ${rc}) at line ${LINENO}. See ${LOG_FILE}"; exit "$rc"' ERR

echo "===== Builder EC2 setup started: $(date) ====="

# Update package metadata and install required tools.
# Amazon Linux 2023 commonly includes curl-minimal; do not install curl,
# because the curl and curl-minimal packages conflict.
dnf update -y
dnf install -y docker git awscli mariadb105

# Ensure a curl-compatible command is available. Prefer the existing
# curl-minimal package on Amazon Linux 2023.
if ! command -v curl >/dev/null 2>&1; then
  dnf install -y curl-minimal
fi

systemctl enable --now docker

# Allow ec2-user to use Docker after a new login/session.
usermod -aG docker ec2-user

# Install Docker Compose as a Docker CLI plugin.
mkdir -p "$COMPOSE_PLUGIN_DIR"
curl -fL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
  -o "${COMPOSE_PLUGIN_DIR}/docker-compose"
chmod 0755 "${COMPOSE_PLUGIN_DIR}/docker-compose"

# Clone the project if it is not already present.
if [[ ! -d "$REPO_DIR/.git" ]]; then
  if [[ -e "$REPO_DIR" ]]; then
    echo "ERROR: ${REPO_DIR} exists but is not a Git repository. Move it aside or inspect it before rerunning." >&2
    exit 1
  fi
  git clone "$REPO_URL" "$REPO_DIR"
else
  echo "Repository already exists; leaving its contents unchanged: $REPO_DIR"
fi

chown -R ec2-user:ec2-user "$REPO_DIR"
find "$REPO_DIR/ecs" -maxdepth 1 -type f -name '*.sh' -exec chmod +x {} + 2>/dev/null || true

echo
echo "Docker version:"
docker --version
echo "Docker Compose version:"
docker compose version
echo
echo "===== Builder EC2 setup completed: $(date) ====="
echo "Log file: $LOG_FILE"
echo "NOTE: Log out and back in (or start a new SSH session) for ec2-user Docker group membership to take effect."
