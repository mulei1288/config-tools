#!/usr/bin/env bash
set -e

DAEMON_JSON="/etc/docker/daemon.json"

log() {
  echo "[config-docker] $1"
}

# 1. root 权限校验
if [ "$(id -u)" -ne 0 ]; then
  log "ERROR: must be run as root"
  exit 1
fi

log "Writing ${DAEMON_JSON}"

# 2. 直接覆盖 daemon.json
cat > "${DAEMON_JSON}" <<'EOF'
{
  "insecure-registries": [
    "registry.bingosoft.net",
    "registry.kube.io:5000",
    "dev.bingosoft.net",
    "registry-dev.bingosoft.net"
  ],
  "debug": true,
  "experimental": true,
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://mirror.baidubce.com",
    "https://registry.docker-cn.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
EOF

# 3. 重启 docker
log "Restarting docker service"

if command -v systemctl >/dev/null 2>&1; then
  systemctl daemon-reexec >/dev/null 2>&1 || true
  systemctl restart docker
else
  service docker restart
fi

log "Docker config applied successfully"
