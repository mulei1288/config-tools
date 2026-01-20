#!/usr/bin/env bash
set -e

DAEMON_JSON="/etc/docker/daemon.json"
BACKUP_SUFFIX="$(date +%Y%m%d%H%M%S)"

log() {
  echo "[config-docker] $1"
}

# root 权限校验
if [ "$(id -u)" -ne 0 ]; then
  log "ERROR: must be run as root"
  exit 1
fi

# 备份旧配置（如果存在）
if [ -f "$DAEMON_JSON" ]; then
  BACKUP_FILE="${DAEMON_JSON}.bak.${BACKUP_SUFFIX}"
  cp "$DAEMON_JSON" "$BACKUP_FILE"
  log "Backup created: $BACKUP_FILE"
fi

log "Writing ${DAEMON_JSON}"

# 覆盖 daemon.json
cat > "$DAEMON_JSON" <<'EOF'
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
    "https://docker.1ms.run",
    "https://hub.rat.dev",
    "https://dockerproxy.net",
    "https://proxy.vvvv.ee"
  ]
}
EOF

log "Restarting docker service"

if command -v systemctl >/dev/null 2>&1; then
  systemctl daemon-reexec >/dev/null 2>&1 || true
  systemctl restart docker
else
  service docker restart
fi

log "Docker config applied successfully"
