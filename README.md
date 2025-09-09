# MikroTik Safe Cycling Firewall

A comprehensive MikroTik RouterOS v7 configuration for implementing safe cycling website filtering on a HAP ac2 router. This configuration creates a restrictive firewall that only allows access to specified educational and safe websites while blocking all other traffic.

## Features

- 🔒 **DNS Server Configuration**: Configures specific DNS servers from `dns_servers.txt`
- 🌐 **VPN Integration**: Template for VPN connection setup
- 🛡️ **DNS Interception**: Intercepts all DNS queries and routes them through configured servers
- 🚫 **DoH/DoT Blocking**: Blocks DNS over HTTPS and DNS over TLS to prevent DNS bypassing
- 📋 **Website Filtering**: Allows access only to websites listed in `allowed_sites.txt`
- 🚧 **Default Deny**: Drops all other traffic for maximum security
- 📄 **Landing Page**: Provides a user-friendly page showing allowed websites

## Files

- `00-main-config.rsc` - Complete configuration script (run this first)
- `01-configure-dns.rsc` - DNS server configuration
- `02-configure-vpn.rsc` - VPN setup template
- `03-dns-interception.rsc` - DNS interception and DoH blocking
- `04-website-filtering.rsc` - Website filtering rules
- `05-landing-page.rsc` - Web server and landing page setup
- `99-utilities.rsc` - Backup, status check, and utility functions
- `landing-page.html` - Landing page HTML file (upload to router)
- `dns_servers.txt` - DNS servers configuration
- `allowed_sites.txt` - Allowed websites list

## Quick Setup

1. **Configure DNS servers** in `dns_servers.txt`:
   ```
   8.8.8.8
   8.8.4.4
   1.1.1.1
   ```

2. **Configure allowed websites** in `allowed_sites.txt`:
   ```
   en.wikipedia.org
   github.com
   stackoverflow.com
   ```

3. **Run the main configuration script**:
   ```
   /import file-name=00-main-config.rsc
   ```

4. **Upload the landing page**:
   - Upload `landing-page.html` to the router
   - Copy it to `/hotspot/index.html` in the router file system

5. **Configure VPN** (manual step):
   - Edit the VPN section in the scripts with your provider's details
   - Configure WireGuard or OpenVPN credentials

## Detailed Setup Instructions

### Prerequisites

- MikroTik HAP ac2 router
- RouterOS v7.x installed
- Administrative access to the router
- VPN service credentials (optional but recommended)

### Step 1: Initial Configuration

Connect to your MikroTik router via Winbox, SSH, or web interface and import the main configuration:

```routeros
/import file-name=00-main-config.rsc
```

### Step 2: Customize Configuration Files

Edit the configuration files to match your requirements:

**DNS Servers (`dns_servers.txt`):**
```
# Primary DNS servers
8.8.8.8
8.8.4.4
1.1.1.1
```

**Allowed Websites (`allowed_sites.txt`):**
```
# Educational websites
en.wikipedia.org
www.wikipedia.org
github.com
stackoverflow.com
developer.mozilla.org
w3schools.com
codecademy.com
khanacademy.org
coursera.org
edx.org
```

### Step 3: VPN Configuration (Optional but Recommended)

Edit the VPN section in `02-configure-vpn.rsc` with your VPN provider's details:

```routeros
# Example WireGuard configuration
/interface wireguard set wg-vpn private-key="YOUR_PRIVATE_KEY"
/interface wireguard peer add interface=wg-vpn \
  public-key="PROVIDER_PUBLIC_KEY" \
  endpoint-address=vpn.provider.com \
  endpoint-port=51820 \
  allowed-address=0.0.0.0/0
/ip address add address=10.0.0.2/24 interface=wg-vpn
/ip route add dst-address=0.0.0.0/0 gateway=wg-vpn
```

### Step 4: Upload Landing Page

1. Upload `landing-page.html` to your router's file system
2. Copy it to the correct location:
   ```routeros
   /file copy src-file=landing-page.html dst-file=hotspot/index.html
   ```

### Step 5: Verification

Run the utility script to check configuration:

```routeros
/import file-name=99-utilities.rsc
```

## Security Features

### DNS Security
- All DNS queries are intercepted and routed through configured DNS servers
- DNS over HTTPS (DoH) is blocked to prevent bypassing
- DNS over TLS (DoT) is blocked
- Known DoH provider IPs are blocked on port 443

### Traffic Filtering
- Default deny policy - all traffic is blocked unless explicitly allowed
- Only traffic to websites in the allowed list is permitted
- Local network traffic is allowed for router management
- ICMP is allowed for basic connectivity testing

### Monitoring
- Firewall rules can be configured to log blocked traffic
- System logs record configuration changes
- Status scripts provide current configuration overview

## Troubleshooting

### Common Issues

1. **Cannot access allowed websites**
   - Check if the domain is in the allowed-sites address list
   - Verify DNS resolution is working
   - Check firewall rules order

2. **DNS not working**
   - Verify DNS servers are configured correctly
   - Check if DNS interception rules are active
   - Test DNS connectivity with ping

3. **VPN not connecting**
   - Verify VPN credentials and configuration
   - Check if VPN traffic is allowed through firewall
   - Ensure VPN interface is properly configured

### Diagnostic Commands

```routeros
# Check DNS configuration
/ip dns print

# View address lists
/ip firewall address-list print

# Check firewall rules
/ip firewall filter print
/ip firewall nat print

# Test connectivity
/ping 8.8.8.8
/tool traceroute 8.8.8.8

# View logs
/log print where topics~"firewall"
```

## Customization

### Adding New Allowed Websites

1. Add the domain to `allowed_sites.txt`
2. Add it to the router's address list:
   ```routeros
   /ip firewall address-list add list=allowed-sites address=newsite.com comment="New Site"
   ```

### Changing DNS Servers

1. Update `dns_servers.txt`
2. Update the router configuration:
   ```routeros
   /ip dns set servers=new.dns.server,another.dns.server
   ```
3. Update firewall rules to allow the new DNS servers

### Modifying the Landing Page

1. Edit `landing-page.html`
2. Re-upload to the router
3. Copy to `/hotspot/index.html`

## Backup and Recovery

### Creating Backups

```routeros
# Create full backup
/system backup save name=safe-cycling-backup

# Export configuration
/export compact file=safe-cycling-config
```

### Restoring Configuration

```routeros
# Restore from backup
/system backup load name=safe-cycling-backup

# Import configuration
/import file-name=safe-cycling-config.rsc
```

## Security Considerations

- This configuration creates a very restrictive network environment
- All traffic not explicitly allowed is blocked
- DNS queries are monitored and controlled
- Regular updates to allowed sites list may be required
- VPN configuration adds an extra layer of security
- Consider implementing time-based access controls for additional security

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review MikroTik RouterOS documentation
3. Consult MikroTik community forums
4. Contact your network administrator

## License

This configuration is provided as-is for educational and safety purposes. Use at your own risk and ensure compliance with local regulations and policies.
