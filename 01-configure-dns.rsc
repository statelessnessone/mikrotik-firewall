# MikroTik RouterOS v7 DNS Configuration Script
# This script configures DNS servers from dns_servers.txt file
# Generated automatically by generate_scripts.sh
# Run this script on MikroTik HAP ac2

:log info "Starting DNS configuration..."

# Configure DNS servers (generated from dns_servers.txt)
/ip dns set servers=8.8.8.8,8.8.4.4,1.1.1.1,9.9.9.9

# Enable DNS cache
/ip dns set cache-size=2048

# Enable DNS query logging for monitoring
/ip dns set query-server-timeout=2s
/ip dns set query-total-timeout=10s

# Set DNS cache max TTL to prevent long-term caching of blocked content
/ip dns set cache-max-ttl=1h

:log info "DNS configuration completed"
:log info "Configured DNS servers: 8.8.8.8,8.8.4.4,1.1.1.1,9.9.9.9"
