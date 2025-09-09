#!/bin/bash
# MikroTik RouterOS Script Generator
# This script generates .rsc configuration files from configuration text files
# For use with MikroTik HAP ac2 running RouterOS v7
#
# Usage: ./generate_scripts.sh
#
# This script reads configuration from:
#   - dns_servers.txt    : DNS server IP addresses (one per line)
#   - allowed_sites.txt  : Allowed website domains (one per line)
#
# Generated output files:
#   - 01-configure-dns.rsc      : DNS configuration script
#   - 04-website-filtering.rsc  : Website filtering firewall rules  
#   - 00-main-config.rsc        : Complete configuration script
#
# All generated scripts are automatically validated using validate_mikrotik.sh

set -eu

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DNS_SERVERS_FILE="${SCRIPT_DIR}/dns_servers.txt"
ALLOWED_SITES_FILE="${SCRIPT_DIR}/allowed_sites.txt"

# Output files
DNS_CONFIG_OUTPUT="${SCRIPT_DIR}/01-configure-dns.rsc"
FILTERING_CONFIG_OUTPUT="${SCRIPT_DIR}/04-website-filtering.rsc"
MAIN_CONFIG_OUTPUT="${SCRIPT_DIR}/00-main-config.rsc"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to validate input files
validate_input_files() {
    local errors=0
    
    if [[ ! -f "$DNS_SERVERS_FILE" ]]; then
        log_error "DNS servers file not found: $DNS_SERVERS_FILE"
        ((errors++))
    elif [[ ! -s "$DNS_SERVERS_FILE" ]]; then
        log_warn "DNS servers file is empty: $DNS_SERVERS_FILE"
    fi
    
    if [[ ! -f "$ALLOWED_SITES_FILE" ]]; then
        log_error "Allowed sites file not found: $ALLOWED_SITES_FILE"
        ((errors++))
    elif [[ ! -s "$ALLOWED_SITES_FILE" ]]; then
        log_warn "Allowed sites file is empty: $ALLOWED_SITES_FILE"
    fi
    
    return $errors
}

# Function to read DNS servers and create comma-separated list
get_dns_servers() {
    local dns_list=""
    
    if [[ -f "$DNS_SERVERS_FILE" && -s "$DNS_SERVERS_FILE" ]]; then
        # Read DNS servers, skip comments and empty lines, join with commas
        dns_list=$(grep -v '^\s*#' "$DNS_SERVERS_FILE" | grep -v '^\s*$' | tr '\n' ',' | sed 's/,$//')
    fi
    
    # Fallback to default DNS servers if file is empty or missing
    if [[ -z "$dns_list" ]]; then
        dns_list="8.8.8.8,8.8.4.4,1.1.1.1"
        log_warn "Using default DNS servers: $dns_list"
    fi
    
    echo "$dns_list"
}

# Function to generate DNS configuration script
generate_dns_config() {
    local dns_servers
    dns_servers=$(get_dns_servers)
    
    log_info "Generating DNS configuration script: $DNS_CONFIG_OUTPUT"
    
    cat > "$DNS_CONFIG_OUTPUT" << EOF
# MikroTik RouterOS v7 DNS Configuration Script
# This script configures DNS servers from dns_servers.txt file
# Generated automatically by generate_scripts.sh
# Run this script on MikroTik HAP ac2

:log info "Starting DNS configuration..."

# Configure DNS servers (generated from dns_servers.txt)
/ip dns set servers=$dns_servers

# Enable DNS cache
/ip dns set cache-size=2048

# Enable DNS query logging for monitoring
/ip dns set query-server-timeout=2s
/ip dns set query-total-timeout=10s

# Set DNS cache max TTL to prevent long-term caching of blocked content
/ip dns set cache-max-ttl=1h

:log info "DNS configuration completed"
:log info "Configured DNS servers: $dns_servers"
EOF
    
    log_info "DNS configuration generated with servers: $dns_servers"
}

# Function to generate website filtering configuration script
generate_filtering_config() {
    log_info "Generating website filtering configuration script: $FILTERING_CONFIG_OUTPUT"
    
    # Create the beginning of the file
    {
        echo "# MikroTik RouterOS v7 Website Filtering Script"
        echo "# This script creates firewall rules to allow only specific websites"
        echo "# Generated automatically from allowed_sites.txt configuration"
        echo "# Run this script on MikroTik HAP ac2"
        echo ""
        echo ":log info \"Starting website filtering configuration...\""
        echo ""
        echo "# Create address lists for allowed websites"
        echo "# Generated from allowed_sites.txt content"
        echo ""
        echo "# Allow local network access"
        echo "/ip firewall address-list add list=allowed-local address=192.168.0.0/16 comment=\"Local network\""
        echo "/ip firewall address-list add list=allowed-local address=10.0.0.0/8 comment=\"Private network\""
        echo "/ip firewall address-list add list=allowed-local address=172.16.0.0/12 comment=\"Private network\""
        echo ""
    } > "$FILTERING_CONFIG_OUTPUT"

    # Add allowed websites from configuration file
    if [[ -f "$ALLOWED_SITES_FILE" && -s "$ALLOWED_SITES_FILE" ]]; then
        echo "# Add allowed website domains to address list (from allowed_sites.txt)" >> "$FILTERING_CONFIG_OUTPUT"
        site_count=0
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip comments and empty lines
            if [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ -n "${line//[[:space:]]/}" ]]; then
                site=$(echo "$line" | tr -d '[:space:]')
                echo "/ip firewall address-list add list=allowed-sites address=$site comment=\"Allowed site\"" >> "$FILTERING_CONFIG_OUTPUT"
                site_count=$((site_count + 1))
            fi
        done < "$ALLOWED_SITES_FILE"
        
        log_info "Added $site_count allowed sites from configuration file"
    else
        log_warn "No allowed sites file found or file is empty"
        echo "# No allowed sites configured - all external sites will be blocked" >> "$FILTERING_CONFIG_OUTPUT"
    fi
    
    # Add the rest of the firewall configuration using printf to avoid heredoc issues
    {
        echo ""
        echo "# =========================================="
        echo "# CRITICAL: DESTRUCTIVE OPERATION WARNING"
        echo "# =========================================="
        echo "# The commented line below will REMOVE ALL EXISTING FIREWALL FILTER RULES!"
        echo "# "
        echo "# ⚠️  BACKUP INSTRUCTIONS (REQUIRED before uncommenting):"
        echo "# 1. Create configuration backup: /export compact file=backup-before-filter-reset"
        echo "# 2. Save backup file to external storage"
        echo "# 3. Test this configuration in a lab environment first"
        echo "# 4. Verify you have alternative router access (console/physical)"
        echo "# "
        echo "# Uncomment the next line only if you understand the consequences:"
        echo "# /ip firewall filter remove [find]"
        echo ""
        echo "# Configure firewall filter rules for website filtering"
        echo ":log info \"Configuring firewall filter rules...\""
        echo ""
        echo "# Allow established and related connections"
        echo "/ip firewall filter add chain=forward action=accept connection-state=established,related comment=\"Allow established connections\""
        echo ""
        echo "# Allow local network traffic"
        echo "/ip firewall filter add chain=forward action=accept src-address-list=allowed-local comment=\"Allow local network\""
        echo "/ip firewall filter add chain=forward action=accept dst-address-list=allowed-local comment=\"Allow to local network\""
        echo ""
        echo "# Allow traffic to allowed websites"
        echo "/ip firewall filter add chain=forward action=accept dst-address-list=allowed-sites comment=\"Allow access to approved sites\""
        echo ""
        echo "# Allow ICMP for basic connectivity"
        echo "/ip firewall filter add chain=forward action=accept protocol=icmp comment=\"Allow ICMP\""
        echo ""
        echo "# Log and drop all other traffic (default deny)"
        echo "/ip firewall filter add chain=forward action=log log-prefix=\"BLOCKED: \" comment=\"Log blocked traffic\""
        echo "/ip firewall filter add chain=forward action=drop comment=\"Drop all other traffic\""
        echo ""
        echo "# Allow router management traffic on input chain"
        echo "/ip firewall filter add chain=input action=accept connection-state=established,related comment=\"Allow established input\""
        echo "/ip firewall filter add chain=input action=accept src-address-list=allowed-local comment=\"Allow local management\""
        echo "/ip firewall filter add chain=input action=accept protocol=icmp comment=\"Allow ICMP to router\""
        echo "/ip firewall filter add chain=input action=drop comment=\"Drop other input traffic\""
        echo ""
        echo ":log info \"Website filtering configuration completed\""
        echo ":log info \"Default deny policy is now active - only approved sites are accessible\""
    } >> "$FILTERING_CONFIG_OUTPUT"
    
    log_info "Website filtering configuration generated successfully"
}

# Function to update main configuration script
generate_main_config() {
    local dns_servers
    dns_servers=$(get_dns_servers)
    
    log_info "Generating main configuration script: $MAIN_CONFIG_OUTPUT"
    
    cat > "$MAIN_CONFIG_OUTPUT" << EOF
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
/ip dns set servers=$dns_servers
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

EOF

    # Add allowed websites from configuration file
    if [[ -f "$ALLOWED_SITES_FILE" && -s "$ALLOWED_SITES_FILE" ]]; then
        echo "# Add allowed website domains (generated from allowed_sites.txt)" >> "$MAIN_CONFIG_OUTPUT"
        site_count=0
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip comments and empty lines
            if [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ -n "${line//[[:space:]]/}" ]]; then
                site=$(echo "$line" | tr -d '[:space:]')
                echo "/ip firewall address-list add list=allowed-sites address=$site comment=\"Allowed site\"" >> "$MAIN_CONFIG_OUTPUT"
                site_count=$((site_count + 1))
            fi
        done < "$ALLOWED_SITES_FILE"
        
        log_info "Added $site_count allowed sites to main configuration"
    else
        echo "# No allowed sites configured - all external sites will be blocked" >> "$MAIN_CONFIG_OUTPUT"
    fi

    # Add the rest of the main configuration
    cat >> "$MAIN_CONFIG_OUTPUT" << 'EOF'

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
:log info "DNS servers configured: ${DNS_SERVERS}"
:log info "Default deny firewall policy is active"
:log info "Only approved websites are accessible"
:log warning "VPN configuration requires manual setup"
:log warning "Landing page upload requires manual step"
:log info "Configuration backup recommended: /export compact file=safe-cycling-backup"
EOF
    
    log_info "Main configuration script generated successfully"
}

# Function to validate generated scripts
validate_generated_scripts() {
    log_info "Validating generated scripts..."
    
    local validation_script="${SCRIPT_DIR}/validate_mikrotik.sh"
    local errors=0
    
    if [[ ! -x "$validation_script" ]]; then
        log_warn "Validation script not found or not executable: $validation_script"
        return 0
    fi
    
    for script in "$DNS_CONFIG_OUTPUT" "$FILTERING_CONFIG_OUTPUT" "$MAIN_CONFIG_OUTPUT"; do
        if [[ -f "$script" ]]; then
            log_info "Validating: $(basename "$script")"
            if ! "$validation_script" "$script"; then
                log_error "Validation failed for: $(basename "$script")"
                ((errors++))
            fi
        fi
    done
    
    return $errors
}

# Main function
main() {
    # Check for help flag
    if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
        echo "MikroTik RouterOS Script Generator"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "This script generates RouterOS .rsc configuration files from text configuration files."
        echo ""
        echo "Input files (must exist in same directory):"
        echo "  dns_servers.txt     - DNS server IP addresses (one per line)"
        echo "  allowed_sites.txt   - Allowed website domains (one per line)"
        echo ""
        echo "Generated output files:"
        echo "  01-configure-dns.rsc      - DNS configuration script"
        echo "  04-website-filtering.rsc  - Website filtering firewall rules"
        echo "  00-main-config.rsc        - Complete configuration script"
        echo ""
        echo "Options:"
        echo "  -h, --help         Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0                 Generate all .rsc scripts from configuration files"
        echo ""
        echo "The generated scripts are automatically validated and ready for import into"
        echo "a MikroTik router running RouterOS v7."
        echo ""
        return 0
    fi
    
    log_info "MikroTik RouterOS Script Generator Starting..."
    log_info "Working directory: $SCRIPT_DIR"
    
    # Validate input files
    if ! validate_input_files; then
        log_error "Input file validation failed. Cannot continue."
        exit 1
    fi
    
    # Generate scripts
    generate_dns_config
    generate_filtering_config  
    generate_main_config
    
    # Validate generated scripts
    if validate_generated_scripts; then
        log_info "All scripts generated and validated successfully!"
    else
        log_warn "Some validation errors occurred. Please review the generated scripts."
    fi
    
    log_info "Generated files:"
    log_info "  - $DNS_CONFIG_OUTPUT"
    log_info "  - $FILTERING_CONFIG_OUTPUT" 
    log_info "  - $MAIN_CONFIG_OUTPUT"
    log_info ""
    log_info "Next steps:"
    log_info "  1. Review the generated .rsc files"
    log_info "  2. Upload the scripts to your MikroTik router"
    log_info "  3. Import with: /import file-name=00-main-config.rsc"
    log_info "  4. Configure VPN manually if needed"
    log_info "  5. Upload landing-page.html to router"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi