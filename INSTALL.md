# MikroTik Safe Cycling Installation Guide

## Quick Installation Steps

1. **Connect to your MikroTik HAP ac2**
   - Use Winbox, SSH, or web interface
   - Ensure you have administrative access

2. **Upload all .rsc files to the router**
   ```
   Files to upload:
   - 00-main-config.rsc
   - 01-configure-dns.rsc
   - 02-configure-vpn.rsc
   - 03-dns-interception.rsc
   - 04-website-filtering.rsc
   - 05-landing-page.rsc
   - 99-utilities.rsc
   ```

3. **Upload the landing page**
   ```
   - Upload landing-page.html to the router
   ```

4. **Run the main configuration**
   ```routeros
   /import file-name=00-main-config.rsc
   ```

5. **Configure the landing page**
   ```routeros
   /file copy src-file=landing-page.html dst-file=hotspot/index.html
   ```

6. **Configure your VPN (Optional but recommended)**
   - Edit the VPN settings in the scripts with your provider's details
   - Re-run the VPN configuration script

## What gets configured:

✅ **DNS Configuration**
- Primary DNS servers: 8.8.8.8, 8.8.4.4, 1.1.1.1
- DNS cache optimization
- Query timeout settings

✅ **Security Features**
- DNS interception (all DNS queries routed through configured servers)
- DNS over HTTPS (DoH) blocking
- DNS over TLS (DoT) blocking
- Layer 7 filtering for DoH domains

✅ **Website Filtering**
- Only allowed websites accessible (from allowed_sites.txt)
- Default deny policy for all other traffic
- Local network access maintained

✅ **Landing Page**
- User-friendly page showing allowed websites
- Security feature explanations
- Professional appearance

✅ **Monitoring & Utilities**
- Backup creation capabilities
- Status checking scripts
- Configuration validation

## Manual Steps Required:

1. **VPN Configuration**: Replace placeholder values in VPN scripts with your actual provider details
2. **Website List**: Customize allowed_sites.txt for your specific needs
3. **DNS Servers**: Adjust dns_servers.txt if different servers are preferred

## Testing:

Run the utility script to verify configuration:
```routeros
/import file-name=99-utilities.rsc
```

## Backup:

Always create a backup before applying:
```routeros
/system backup save name=pre-safecycling-backup
```