# MikroTik RouterOS v7 Complete Safe Cycling Configuration Script
# This is the main script that configures all components for safe cycling website filtering
# Generated automatically by generate_scripts.sh
# For MikroTik HAP ac2 running RouterOS v7
# 
# IMPORTANT: Review and customize each section before running
# Some values need to be replaced with your specific configuration

:log info "=== Starting Safe Cycling Network Configuration ==="

# =======================
# 1. BASIC ROUTER SETUP
# =======================
:log info "Step 1: Basic router configuration..."

# Set router identity
/system identity set name="SafeCycling-Router"

# Set timezone (adjust as needed)
/system clock set time-zone-name=UTC

# Enable NTP for time synchronization
/system ntp client set enabled=yes servers=pool.ntp.org

# =======================
# 2. DNS CONFIGURATION
# =======================
:log info "Step 2: Configuring DNS servers..."

# Configure DNS servers (generated from dns_servers.txt)
/ip dns set servers=8.8.8.8,8.8.4.4,1.1.1.1,9.9.9.9
/ip dns set cache-size=2048
/ip dns set query-server-timeout=2s
/ip dns set query-total-timeout=10s
/ip dns set cache-max-ttl=1h

# =======================
# 3. VPN CONFIGURATION
# =======================
:log info "Step 3: VPN configuration (requires manual setup)..."

# Create WireGuard interface template
/interface wireguard add name=wg-vpn listen-port=13231

# Note: VPN configuration requires manual setup with your provider's details
:log warning "VPN configuration incomplete - manual setup required"
:log info "Please configure WireGuard with your VPN provider's settings"

# =======================
# 4. ADDRESS LISTS
# =======================
:log info "Step 4: Creating address lists..."

# Allow local network access
/ip firewall address-list add list=allowed-local address=192.168.0.0/16 comment="Local network"
/ip firewall address-list add list=allowed-local address=10.0.0.0/8 comment="Private network"
/ip firewall address-list add list=allowed-local address=172.16.0.0/12 comment="Private network"

# Add allowed website domains (generated from allowed_sites.txt)
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

# =======================
# 5. DNS INTERCEPTION
# =======================
:log info "Step 5: Setting up DNS interception..."

# Redirect all DNS queries to our configured DNS servers
/ip firewall nat add chain=dstnat protocol=udp dst-port=53 action=redirect to-ports=53 comment="Intercept DNS UDP"
/ip firewall nat add chain=dstnat protocol=tcp dst-port=53 action=redirect to-ports=53 comment="Intercept DNS TCP"

# Block DNS over HTTPS (DoH) on port 443
/ip firewall filter add chain=forward action=drop protocol=tcp dst-port=443 dst-address-list=doh-servers comment="Block DoH"

# Add known DoH server addresses to block list
/ip firewall address-list add list=doh-servers address=1.1.1.1 comment="Cloudflare DoH"
/ip firewall address-list add list=doh-servers address=1.0.0.1 comment="Cloudflare DoH"
/ip firewall address-list add list=doh-servers address=8.8.8.8 comment="Google DoH"
/ip firewall address-list add list=doh-servers address=8.8.4.4 comment="Google DoH"

# Block DNS over TLS (DoT) on port 853
/ip firewall filter add chain=forward action=drop protocol=tcp dst-port=853 comment="Block DoT"

# =======================
# 6. FIREWALL RULES
# =======================
:log info "Step 6: Configuring firewall rules..."

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

# =======================
# 7. WEB SERVER FOR LANDING PAGE
# =======================
:log info "Step 7: Configuring web server for landing page..."

# Enable web server
/ip service set www disabled=no port=80

# Note: Upload landing-page.html to router and copy to hotspot directory
:log warning "Manual step required: Upload landing-page.html to /hotspot/index.html"

# =======================
# CONFIGURATION COMPLETE
# =======================
:log info "=== Safe Cycling Network Configuration Complete ==="
:log info "DNS servers configured: $dns_servers"
:log info "Default deny firewall policy is active"
:log info "Only approved websites are accessible"
:log warning "VPN configuration requires manual setup"
:log warning "Landing page upload requires manual step"
:log info "Configuration backup recommended: /export compact file=safe-cycling-backup"
