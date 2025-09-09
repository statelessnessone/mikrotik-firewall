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
