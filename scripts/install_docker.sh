#!/usr/bin/env bash
set -euo pipefail

dnf install -y dnf-plugins-core

if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
fi

dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker

docker version
docker compose version
