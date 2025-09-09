# MikroTik RouterOS v7 Complete Safe Cycling Configuration Script
# This is the main script that configures all components for safe cycling website filtering
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

# Configure DNS servers (from dns_servers.txt)
/ip dns set servers=8.8.8.8,8.8.4.4,1.1.1.1
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
:log info "Step 4: Creating address lists for allowed sites..."

# Remove existing address lists
/ip firewall address-list remove [find list=allowed-local]
/ip firewall address-list remove [find list=allowed-sites]

# Allow local network access
/ip firewall address-list add list=allowed-local address=192.168.0.0/16 comment="Local network"
/ip firewall address-list add list=allowed-local address=10.0.0.0/8 comment="Private network"
/ip firewall address-list add list=allowed-local address=172.16.0.0/12 comment="Private network"

# Add allowed websites (from allowed_sites.txt)
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

# =======================
# 5. DNS INTERCEPTION
# =======================
:log info "Step 5: Configuring DNS interception..."

# Remove existing DNS NAT rules
/ip firewall nat remove [find comment~"Intercept DNS"]

# Intercept all DNS queries
/ip firewall nat add chain=dstnat protocol=udp dst-port=53 action=redirect to-ports=53 comment="Intercept DNS queries - UDP"
/ip firewall nat add chain=dstnat protocol=tcp dst-port=53 action=redirect to-ports=53 comment="Intercept DNS queries - TCP"

# =======================
# 6. FIREWALL RULES
# =======================
:log info "Step 6: Configuring firewall rules..."

# WARNING: This will remove existing firewall rules!
# Comment out the next line if you want to keep existing rules
# /ip firewall filter remove [find]

# Layer 7 protocol for DoH domains
/ip firewall layer7-protocol remove [find name=doh-domains]
/ip firewall layer7-protocol add name=doh-domains regexp="dns\.google|cloudflare-dns\.com|dns\.quad9\.net"

# INPUT chain rules (traffic to router)
/ip firewall filter add chain=input connection-state=established,related action=accept comment="Allow established connections to router"
/ip firewall filter add chain=input src-address-list=allowed-local action=accept comment="Allow local access to router"
/ip firewall filter add chain=input action=drop comment="Drop all other input traffic"

# FORWARD chain rules (traffic through router)
/ip firewall filter add chain=forward connection-state=established,related action=accept comment="Allow established and related connections"
/ip firewall filter add chain=forward src-address-list=allowed-local dst-address-list=allowed-local action=accept comment="Allow local network traffic"
/ip firewall filter add chain=forward dst-address-list=allowed-sites action=accept comment="Allow access to approved websites"

# Allow DNS to configured servers
/ip firewall filter add chain=forward dst-address=8.8.8.8 dst-port=53 protocol=udp action=accept comment="Allow DNS to Google DNS"
/ip firewall filter add chain=forward dst-address=8.8.4.4 dst-port=53 protocol=udp action=accept comment="Allow DNS to Google DNS"
/ip firewall filter add chain=forward dst-address=1.1.1.1 dst-port=53 protocol=udp action=accept comment="Allow DNS to Cloudflare DNS"

# Block DNS over HTTPS and DNS over TLS
/ip firewall filter add chain=forward dst-address=8.8.8.8 dst-port=443 protocol=tcp action=drop comment="Block Google DoH"
/ip firewall filter add chain=forward dst-address=8.8.4.4 dst-port=443 protocol=tcp action=drop comment="Block Google DoH"
/ip firewall filter add chain=forward dst-address=1.1.1.1 dst-port=443 protocol=tcp action=drop comment="Block Cloudflare DoH"
/ip firewall filter add chain=forward dst-address=1.0.0.1 dst-port=443 protocol=tcp action=drop comment="Block Cloudflare DoH"
/ip firewall filter add chain=forward dst-port=853 protocol=tcp action=drop comment="Block DNS over TLS (DoT)"
/ip firewall filter add chain=forward layer7-protocol=doh-domains action=drop comment="Block DoH domains"

# Allow ICMP for basic connectivity
/ip firewall filter add chain=forward protocol=icmp action=accept comment="Allow ICMP"

# Default deny rule (must be last)
/ip firewall filter add chain=forward action=drop comment="Drop all other traffic"

# =======================
# 7. WEB SERVER
# =======================
:log info "Step 7: Enabling web server for landing page..."

# Enable web server
/ip service set www disabled=no port=80

# =======================
# 8. LOGGING AND MONITORING
# =======================
:log info "Step 8: Configuring logging..."

# Enable firewall logging for dropped packets (optional)
# /ip firewall filter set [find comment="Drop all other traffic"] log=yes log-prefix="BLOCKED: "

# =======================
# CONFIGURATION COMPLETE
# =======================
:log info "=== Safe Cycling Network Configuration Complete ==="
:log info "Configuration Summary:"
:log info "- DNS servers: 8.8.8.8, 8.8.4.4, 1.1.1.1"
:log info "- DNS interception: Enabled"
:log info "- DoH/DoT blocking: Enabled"
:log info "- Website filtering: Only allowed sites permitted"
:log info "- Web server: Enabled on port 80"
:log info ""
:log warning "MANUAL STEPS REQUIRED:"
:log warning "1. Configure VPN connection with your provider's details"
:log warning "2. Upload landing-page.html to /hotspot/index.html"
:log warning "3. Test all functionality before deploying"
:log warning "4. Backup configuration: /export file=safe-cycling-backup"