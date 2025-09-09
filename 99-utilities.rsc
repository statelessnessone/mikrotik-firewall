# MikroTik RouterOS v7 Utility Scripts
# Helper scripts for managing the Safe Cycling configuration

# =======================
# BACKUP CONFIGURATION
# =======================
:log info "Creating configuration backup..."
/export compact file=safe-cycling-backup-$([/system clock get date])

# =======================
# SHOW CURRENT STATUS
# =======================
:put "=== Safe Cycling Network Status ==="
:put ""

:put "DNS Configuration:"
:put ("DNS Servers: " . [/ip dns get servers])
:put ("Cache Size: " . [/ip dns get cache-size])
:put ""

:put "Address Lists:"
:put "Allowed Local Networks:"
/ip firewall address-list print where list=allowed-local
:put ""
:put "Allowed Websites:"
/ip firewall address-list print where list=allowed-sites
:put ""

:put "Firewall Rules:"
:put "Filter Rules Count: $[/ip firewall filter print count-only]"
:put "NAT Rules Count: $[/ip firewall nat print count-only]"
:put ""

:put "Services:"
:put ("Web Server: " . [/ip service get www disabled])
:put ""

# =======================
# RESET CONFIGURATION
# =======================
# Uncomment the following section to reset the configuration
# WARNING: This will remove all firewall rules and address lists!

# :log warning "Resetting Safe Cycling configuration..."
# /ip firewall filter remove [find comment~"Safe Cycling"]
# /ip firewall nat remove [find comment~"Intercept DNS"]
# /ip firewall address-list remove [find list=allowed-local]
# /ip firewall address-list remove [find list=allowed-sites]
# /ip firewall layer7-protocol remove [find name=doh-domains]
# :log info "Configuration reset complete"

# =======================
# TEST CONNECTIVITY
# =======================
:put "Testing DNS connectivity..."
:do {
    :local result [/ping 8.8.8.8 count=3]
    :put ("DNS Server 8.8.8.8: " . $result . "% packet loss")
} on-error={
    :put "DNS Server 8.8.8.8: Failed to ping"
}

:put ""
:put "=== Status Check Complete ==="