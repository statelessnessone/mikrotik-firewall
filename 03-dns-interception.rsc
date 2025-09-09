# MikroTik RouterOS v7 DNS Interception and DoH Blocking Script
# This script intercepts all DNS queries and blocks DNS over HTTPS
# Run this script on MikroTik HAP ac2

:log info "Starting DNS interception configuration..."

# Intercept all DNS queries and redirect to local DNS
# This ensures all DNS queries go through our configured DNS servers
/ip firewall nat add chain=dstnat protocol=udp dst-port=53 action=redirect to-ports=53 \
  comment="Intercept DNS queries - UDP"

/ip firewall nat add chain=dstnat protocol=tcp dst-port=53 action=redirect to-ports=53 \
  comment="Intercept DNS queries - TCP"

# Block DNS over HTTPS (DoH) - Port 443 to known DoH providers
# Google DoH
/ip firewall filter add chain=forward dst-address=8.8.8.8 dst-port=443 protocol=tcp action=drop \
  comment="Block Google DoH"
/ip firewall filter add chain=forward dst-address=8.8.4.4 dst-port=443 protocol=tcp action=drop \
  comment="Block Google DoH"

# Cloudflare DoH
/ip firewall filter add chain=forward dst-address=1.1.1.1 dst-port=443 protocol=tcp action=drop \
  comment="Block Cloudflare DoH"
/ip firewall filter add chain=forward dst-address=1.0.0.1 dst-port=443 protocol=tcp action=drop \
  comment="Block Cloudflare DoH"

# Quad9 DoH
/ip firewall filter add chain=forward dst-address=9.9.9.9 dst-port=443 protocol=tcp action=drop \
  comment="Block Quad9 DoH"

# OpenDNS DoH
/ip firewall filter add chain=forward dst-address=208.67.222.222 dst-port=443 protocol=tcp action=drop \
  comment="Block OpenDNS DoH"
/ip firewall filter add chain=forward dst-address=208.67.220.220 dst-port=443 protocol=tcp action=drop \
  comment="Block OpenDNS DoH"

# Block DNS over TLS (DoT) - Port 853
/ip firewall filter add chain=forward dst-port=853 protocol=tcp action=drop \
  comment="Block DNS over TLS (DoT)"

# Block common DoH domains (this requires Layer 7 filtering)
# Note: This is a simplified approach. Full implementation would require more comprehensive domain blocking
/ip firewall layer7-protocol add name=doh-domains regexp="dns\.google|cloudflare-dns\.com|dns\.quad9\.net"
/ip firewall filter add chain=forward layer7-protocol=doh-domains action=drop \
  comment="Block DoH domains"

:log info "DNS interception and DoH blocking configured"
:log info "All DNS queries will be intercepted and routed through configured DNS servers"
:log info "DNS over HTTPS and DNS over TLS have been blocked"