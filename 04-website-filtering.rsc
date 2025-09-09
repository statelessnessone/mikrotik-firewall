# MikroTik RouterOS v7 Website Filtering Script
# This script creates firewall rules to allow only specific websites
# Based on allowed_sites.txt configuration
# Run this script on MikroTik HAP ac2

:log info "Starting website filtering configuration..."

# Create address lists for allowed websites
# Note: MikroTik scripting doesn't support file reading directly
# These addresses must be configured based on allowed_sites.txt content

# Allow local network access
/ip firewall address-list add list=allowed-local address=192.168.0.0/16 comment="Local network"
/ip firewall address-list add list=allowed-local address=10.0.0.0/8 comment="Private network"
/ip firewall address-list add list=allowed-local address=172.16.0.0/12 comment="Private network"

# Add allowed website domains to address list (manually configured from allowed_sites.txt)
# Educational and safe cycling websites
/ip firewall address-list add list=allowed-sites address=en.wikipedia.org comment="Wikipedia"
/ip firewall address-list add list=allowed-sites address=www.wikipedia.org comment="Wikipedia"
/ip firewall address-list add list=allowed-sites address=github.com comment="GitHub"
/ip firewall address-list add list=allowed-sites address=stackoverflow.com comment="Stack Overflow"
/ip firewall address-list add list=allowed-sites address=developer.mozilla.org comment="MDN Web Docs"
/ip firewall address-list add list=allowed-sites address=w3schools.com comment="W3Schools"
/ip firewall address-list add list=allowed-sites address=codecademy.com comment="Codecademy"
/ip firewall address-list add list=allowed-sites address=khanacademy.org comment="Khan Academy"
/ip firewall address-list add list=allowed-sites address=coursera.org comment="Coursera"
/ip firewall address-list add list=allowed-sites address=edx.org comment="edX"

# ==========================================
# CRITICAL: DESTRUCTIVE OPERATION WARNING
# ==========================================
# The commented line below will REMOVE ALL EXISTING FIREWALL FILTER RULES!
# 
# ⚠️  BACKUP INSTRUCTIONS (REQUIRED before uncommenting):
# 1. Create configuration backup: /export compact file=backup-before-filter-reset
# 2. Save backup file to external storage  
# 3. Test this configuration in a lab environment first
# 4. Verify you have alternative router access (console/physical)
# 
# ⚠️  RISK ASSESSMENT:
# - Will delete ALL current firewall filter rules
# - May disconnect all network traffic immediately
# - Could lock you out of router permanently
# - Recovery requires physical access if misconfigured
#
# Only uncomment if you understand and accept these risks:
# /ip firewall filter remove [find]

# Allow established and related connections
/ip firewall filter add chain=forward connection-state=established,related action=accept \
  comment="Allow established and related connections"

# Allow local network traffic
/ip firewall filter add chain=forward src-address-list=allowed-local action=accept \
  comment="Allow local network traffic"
/ip firewall filter add chain=forward dst-address-list=allowed-local action=accept \
  comment="Allow local network traffic"

# Allow traffic to allowed websites
/ip firewall filter add chain=forward dst-address-list=allowed-sites action=accept \
  comment="Allow access to approved websites"

# Allow DNS traffic to configured DNS servers
/ip firewall filter add chain=forward dst-address=8.8.8.8 dst-port=53 protocol=udp action=accept \
  comment="Allow DNS to Google DNS"
/ip firewall filter add chain=forward dst-address=8.8.4.4 dst-port=53 protocol=udp action=accept \
  comment="Allow DNS to Google DNS"
/ip firewall filter add chain=forward dst-address=1.1.1.1 dst-port=53 protocol=udp action=accept \
  comment="Allow DNS to Cloudflare DNS"

# Allow ICMP (ping) for basic connectivity testing
/ip firewall filter add chain=forward protocol=icmp action=accept \
  comment="Allow ICMP"

# Block all other traffic (default deny)
/ip firewall filter add chain=forward action=drop \
  comment="Drop all other traffic"

# Input chain rules for router access
/ip firewall filter add chain=input connection-state=established,related action=accept \
  comment="Allow established connections to router"
/ip firewall filter add chain=input src-address-list=allowed-local action=accept \
  comment="Allow local access to router"
/ip firewall filter add chain=input action=drop \
  comment="Drop all other input traffic"

:log info "Website filtering configuration completed"
:log info "Only traffic to allowed websites and local networks is permitted"
:log info "All other traffic is blocked by default"