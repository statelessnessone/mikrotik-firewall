# MikroTik RouterOS v7 DNS Configuration Script
# This script configures DNS servers from dns_servers.txt file
# Run this script on MikroTik HAP ac2

:log info "Starting DNS configuration..."

# Read DNS servers from external source (manual configuration required)
# Note: MikroTik scripting doesn't support file reading directly
# DNS servers must be configured manually or through external management

# Configure DNS servers (replace with servers from dns_servers.txt)
/ip dns set servers=8.8.8.8,8.8.4.4,1.1.1.1

# Enable DNS cache
/ip dns set cache-size=2048

# Enable DNS query logging for monitoring
/ip dns set query-server-timeout=2s
/ip dns set query-total-timeout=10s

# Set DNS cache max TTL to prevent long-term caching of blocked content
/ip dns set cache-max-ttl=1h

:log info "DNS configuration completed"
:log info "Configured DNS servers: 8.8.8.8, 8.8.4.4, 1.1.1.1"