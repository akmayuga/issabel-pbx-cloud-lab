#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <peer-name> [server-public-hostname-or-ip]"
  exit 1
fi

peer_name="$1"
endpoint_host="${2:-$(curl -fsS https://ifconfig.me/ip)}"
wg_config_dir="/etc/wireguard"
wg_iface="wg0"
listen_port="${WIREGUARD_PORT:-51820}"

dnf install -y wireguard-tools

mkdir -p "$wg_config_dir"
chmod 700 "$wg_config_dir"

server_priv="$(wg genkey)"
server_pub="$(printf "%s" "$server_priv" | wg pubkey)"
peer_priv="$(wg genkey)"
peer_pub="$(printf "%s" "$peer_priv" | wg pubkey)"

cat > "$wg_config_dir/$wg_iface.conf" <<EOF
[Interface]
PrivateKey = $server_priv
Address = 10.254.254.1/24
ListenPort = $listen_port
SaveConfig = false

[Peer]
PublicKey = $peer_pub
AllowedIPs = 10.254.254.2/32
EOF

cat > "$wg_config_dir/$peer_name.conf" <<EOF
[Interface]
PrivateKey = $peer_priv
Address = 10.254.254.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = $server_pub
Endpoint = $endpoint_host:$listen_port
AllowedIPs = 10.254.254.0/24
PersistentKeepalive = 25
EOF

chmod 600 "$wg_config_dir/$wg_iface.conf" "$wg_config_dir/$peer_name.conf"
systemctl enable --now "wg-quick@$wg_iface"

echo "WireGuard server public key: $server_pub"
echo "Peer config: $wg_config_dir/$peer_name.conf"
