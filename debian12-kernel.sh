#!/usr/bin/env bash
set -e

echo "=== Kernel optimization for Debian 12 ==="

SYSCTL_FILE="/etc/sysctl.d/99-reverse-proxy.conf"

echo "=== Backup existing sysctl ==="
cp /etc/sysctl.conf /etc/sysctl.conf.bak.$(date +%s)

echo "=== Writing kernel params to ${SYSCTL_FILE} ==="
cat > ${SYSCTL_FILE} << 'EOF'
# ===============================
# Reverse Proxy / Web Optimization
# Debian 12
# ===============================

# --- File descriptors ---
fs.file-max = 2097152

# --- Network core ---
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 32768
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

# --- TCP memory ---
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# --- TCP connection handling ---
net.ipv4.tcp_max_syn_backlog = 32768
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 5

# --- TCP performance ---
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_congestion_control = bbr

# --- Port range ---
net.ipv4.ip_local_port_range = 10240 65535

# --- ICMP / basic protection ---
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# --- Disable source routing ---
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# --- Disable redirects ---
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
EOF

echo "=== Apply sysctl settings ==="
sysctl --system

echo "=== Increase limits ==="
cat >> /etc/security/limits.conf << 'EOF'

# Reverse Proxy limits
* soft nofile 1048576
* hard nofile 1048576
EOF

echo "=== Done ==="
echo "✔ Kernel parameters optimized"
echo "✔ Re-login required for limits.conf to take effect"
