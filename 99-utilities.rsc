# MikroTik RouterOS v7 Utility Scripts
# Helper scripts for managing the Safe Cycling configuration

# =======================
# BACKUP CONFIGURATION
# =======================
:log info "Creating configuration backup..."
/export compact file="safe-cycling-backup-$([:pick [/system clock get date] 7 11])-$([:pick [/system clock get date] 0 3])-$([:pick [/system clock get date] 4 6])"

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

# ==========================================
# CRITICAL: CONFIGURATION RESET SECTION
# ==========================================
# ⚠️  EXTREME CAUTION: DESTRUCTIVE OPERATIONS BELOW
# 
# The following commands will COMPLETELY REMOVE Safe Cycling configuration:
# - ALL firewall filter rules with "Safe Cycling" comments
# - ALL NAT rules with "Intercept DNS" comments  
# - ALL address lists (allowed-local, allowed-sites)
# - Layer 7 protocols (doh-domains)
#
# 🛡️  MANDATORY BACKUP STEPS (Complete BEFORE uncommenting):
# 1. Create full backup: /export compact file=FULL-BACKUP-$([:pick [/system clock get date] 0 11])
# 2. Save backup to external storage (USB/download)
# 3. Document current configuration settings
# 4. Ensure you have physical/console access to router
# 5. Test recovery procedure in lab environment
#
# ⚠️  RISKS & CONSEQUENCES:
# - Complete loss of Safe Cycling firewall protection
# - All network filtering will be removed
# - May require complete reconfiguration
# - Could result in unrestricted internet access
# - Recovery requires backup restoration or manual reconfiguration
#
# 📋 VERIFICATION CHECKLIST (Mark each before proceeding):
# [ ] Full configuration backup created and verified
# [ ] Backup saved to external/safe location  
# [ ] Physical router access confirmed available
# [ ] Recovery procedure tested and documented
# [ ] Alternative internet filtering in place (if required)
# [ ] Change window scheduled with stakeholders notified
#
# ⚠️  TO PROCEED: Only uncomment the reset section below if ALL above steps completed:

# :log warning "STARTING Safe Cycling configuration reset - THIS WILL REMOVE ALL FILTERING"
# /ip firewall filter remove [find comment~"Safe Cycling"]
# /ip firewall nat remove [find comment~"Intercept DNS"]
# /ip firewall address-list remove [find list=allowed-local]
# /ip firewall address-list remove [find list=allowed-sites]
# /ip firewall layer7-protocol remove [find name=doh-domains]
# :log info "Configuration reset complete - NETWORK FILTERING REMOVED"

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