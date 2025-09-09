# MikroTik RouterOS v7 Website Filtering Script
# This script creates firewall rules to allow only specific websites
# Generated automatically from allowed_sites.txt configuration
# Run this script on MikroTik HAP ac2

:log info "Starting website filtering configuration..."

# Create address lists for allowed websites
# Generated from allowed_sites.txt content

# Allow local network access
/ip firewall address-list add list=allowed-local address=192.168.0.0/16 comment="Local network"
/ip firewall address-list add list=allowed-local address=10.0.0.0/8 comment="Private network"
/ip firewall address-list add list=allowed-local address=172.16.0.0/12 comment="Private network"

# Add allowed website domains to address list (from allowed_sites.txt)
/ip firewall address-list add list=allowed-sites address=en.wikipedia.org comment="Allowed site"
/ip firewall address-list add list=allowed-sites address=www.wikipedia.org comment="Allowed site"
/ip firewall address-list add list=allowed-sites address=github.com comment="Allowed site"
/ip firewall address-list add list=allowed-sites address=stackoverflow.com comment="Allowed site"
/ip firewall address-list add list=allowed-sites address=developer.mozilla.org comment="Allowed site"
/ip firewall address-list add list=allowed-sites address=w3schools.com comment="Allowed site"
/ip firewall address-list add list=allowed-sites address=codecademy.com comment="Allowed site"
/ip firewall address-list add list=allowed-sites address=khanacademy.org comment="Allowed site"
/ip firewall address-list add list=allowed-sites address=coursera.org comment="Allowed site"
/ip firewall address-list add list=allowed-sites address=edx.org comment="Allowed site"
/ip firewall address-list add list=allowed-sites address=google.com comment="Allowed site"

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
# Uncomment the next line only if you understand the consequences:
# /ip firewall filter remove [find]

# Configure firewall filter rules for website filtering
:log info "Configuring firewall filter rules..."

# Allow established and related connections
/ip firewall filter add chain=forward action=accept connection-state=established,related comment="Allow established connections"

# Allow local network traffic
/ip firewall filter add chain=forward action=accept src-address-list=allowed-local comment="Allow local network"
/ip firewall filter add chain=forward action=accept dst-address-list=allowed-local comment="Allow to local network"

# Allow traffic to allowed websites
/ip firewall filter add chain=forward action=accept dst-address-list=allowed-sites comment="Allow access to approved sites"

# Allow ICMP for basic connectivity
/ip firewall filter add chain=forward action=accept protocol=icmp comment="Allow ICMP"

# Log and drop all other traffic (default deny)
/ip firewall filter add chain=forward action=log log-prefix="BLOCKED: " comment="Log blocked traffic"
/ip firewall filter add chain=forward action=drop comment="Drop all other traffic"

# Allow router management traffic on input chain
/ip firewall filter add chain=input action=accept connection-state=established,related comment="Allow established input"
/ip firewall filter add chain=input action=accept src-address-list=allowed-local comment="Allow local management"
/ip firewall filter add chain=input action=accept protocol=icmp comment="Allow ICMP to router"
/ip firewall filter add chain=input action=drop comment="Drop other input traffic"

:log info "Website filtering configuration completed"
:log info "Default deny policy is now active - only approved sites are accessible"
