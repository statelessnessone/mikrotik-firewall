# Mikrotik Firewall Configuration Scripts

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Project Overview
This repository contains RouterOS scripts for configuring a Mikrotik HAP ac2 router running RouterOS v7. The scripts implement a 'safe browsing' firewall that:
- Configures DNS servers from `dns_servers.txt`
- Creates VPN connections to specific endpoints
- Drops all traffic except to allowed websites listed in `allowed_sites.txt`
- Intercepts DNS queries and routes them to configured DNS servers
- Blocks DNS over HTTPS queries
- Provides landing/warning pages for blocked content

## Working Effectively

### Repository Setup and Validation
- Clone and navigate to the repository:
  ```bash
  git clone <repo-url>
  cd mikrotik-firewall
  ```
- **NEVER CANCEL**: All operations complete in under 5 seconds. Set timeouts to 30+ seconds for safety.
- Validate repository structure and configuration files:
  ```bash
  ls -la
  # Should show: README.md, allowed_sites.txt, dns_servers.txt, and any .rsc script files
  ```

### Configuration Files
- **`allowed_sites.txt`**: Contains one website/domain per line for sites that should be accessible
- **`dns_servers.txt`**: Contains one DNS server IP address per line
- Both files can be empty but must exist for script generation to work

### Script Development and Validation
- **ALWAYS** run validation after making changes to RouterOS scripts:
  ```bash
  # Create a basic validation script (if not exists)
  cat > validate_mikrotik.sh << 'EOF'
  #!/bin/bash
  validate_mikrotik_script() {
      local script_file="$1"
      local errors=0
      
      if [[ ! -f "$script_file" ]]; then
          echo "Error: File $script_file not found"
          return 1
      fi
      
      echo "Validating Mikrotik script: $script_file"
      
      while IFS= read -r line; do
          [[ "$line" =~ ^[[:space:]]*# ]] && continue
          [[ "$line" =~ ^[[:space:]]*$ ]] && continue
          
          if [[ "$line" =~ ^[[:space:]]*/ ]]; then
              echo "✓ Command line: $line"
          elif [[ "$line" =~ ^[[:space:]]*add|set ]]; then
              echo "✓ Parameter line: $line"
          else
              echo "⚠ Unknown line format: $line"
              ((errors++))
          fi
      done < "$script_file"
      
      echo "Validation complete. Errors: $errors"
      return $errors
  }
  
  validate_mikrotik_script "$1"
  EOF
  chmod +x validate_mikrotik.sh
  ```
- Validate any RouterOS script file:
  ```bash
  ./validate_mikrotik.sh script_name.rsc
  ```

### Script Generation from Configuration Files
- Generate RouterOS configuration from text files:
  ```bash
  cat > generate_config.sh << 'EOF'
  #!/bin/bash
  generate_mikrotik_config() {
      local allowed_sites_file="allowed_sites.txt"
      local dns_servers_file="dns_servers.txt"
      local output_file="mikrotik_config.rsc"
      
      {
          echo "# Generated Mikrotik RouterOS Configuration"
          echo "# Generated on: $(date)"
          echo ""
      } > "$output_file"
      
      if [[ -f "$dns_servers_file" && -s "$dns_servers_file" ]]; then
          local dns_list
          dns_list=$(tr '\n' ',' < "$dns_servers_file" | sed 's/,$//')
          {
              echo "# Configure DNS servers"
              echo "/ip dns set servers=$dns_list"
              echo ""
          } >> "$output_file"
      fi
      
      if [[ -f "$allowed_sites_file" && -s "$allowed_sites_file" ]]; then
          {
              echo "# Configure allowed sites"
              echo "/ip firewall address-list"
          } >> "$output_file"
          while IFS= read -r site; do
              [[ -n "$site" ]] && echo "add list=allowed_sites address=$site" >> "$output_file"
          done < "$allowed_sites_file"
          echo "" >> "$output_file"
      fi
      
      {
          echo "# Basic firewall configuration"
          echo "/ip firewall filter"
          echo "add chain=forward action=accept dst-address-list=allowed_sites"
          echo "add chain=forward action=drop"
      } >> "$output_file"
      
      echo "Configuration generated: $output_file"
  }
  
  generate_mikrotik_config
  EOF
  chmod +x generate_config.sh
  ```
- Run configuration generation:
  ```bash
  ./generate_config.sh
  ```

### Complete Validation Workflow
- **ALWAYS** run the complete validation after any changes:
  ```bash
  # Generate and validate configuration
  ./generate_config.sh && ./validate_mikrotik.sh mikrotik_config.rsc
  ```
- **NEVER CANCEL**: Validation takes under 1 second. Set timeout to 30+ seconds.
- Validation should show "✓" for all lines and "Errors: 0"

### Code Quality and Linting
- **ALWAYS** run shellcheck on any bash scripts before committing:
  ```bash
  shellcheck *.sh
  ```
- Fix any shellcheck warnings or errors before proceeding
- **NEVER CANCEL**: Shellcheck runs in under 5 seconds. Set timeout to 30+ seconds.

## Validation Scenarios
After making any changes to RouterOS scripts or configuration files, **ALWAYS** validate:

1. **Configuration File Validation**:
   ```bash
   # Check files exist and have content
   [[ -f "allowed_sites.txt" ]] && echo "✅ allowed_sites.txt exists" || echo "❌ Missing allowed_sites.txt"
   [[ -f "dns_servers.txt" ]] && echo "✅ dns_servers.txt exists" || echo "❌ Missing dns_servers.txt"
   [[ -s "allowed_sites.txt" ]] && echo "✅ allowed_sites.txt has content" || echo "⚠️ allowed_sites.txt is empty"
   [[ -s "dns_servers.txt" ]] && echo "✅ dns_servers.txt has content" || echo "⚠️ dns_servers.txt is empty"
   ```

2. **Script Generation Test**:
   ```bash
   # Test script generation works
   ./generate_config.sh
   [[ -f "mikrotik_config.rsc" ]] && echo "✅ Config generated successfully" || echo "❌ Config generation failed"
   ```

3. **Script Syntax Validation**:
   ```bash
   # Validate generated RouterOS script syntax
   ./validate_mikrotik.sh mikrotik_config.rsc
   ```

4. **Manual Review**: 
   - Always manually review generated RouterOS scripts for correctness
   - Verify DNS servers are valid IP addresses
   - Verify website entries are proper domain names
   - Check that firewall rules follow expected patterns

## Repository Structure
```
mikrotik-firewall/
├── README.md                 # Project documentation
├── allowed_sites.txt        # Websites allowed through firewall (one per line)
├── dns_servers.txt          # DNS server IP addresses (one per line)
├── generate_config.sh       # Script to generate RouterOS config from txt files
├── validate_mikrotik.sh     # Script to validate RouterOS syntax
└── *.rsc                    # Generated RouterOS configuration files
```

## Important Notes
- **RouterOS Script Format**: Scripts use .rsc extension and RouterOS command syntax
- **No Hardware Testing**: Scripts can only be syntax-validated without actual Mikrotik hardware
- **Configuration Management**: Always update configuration files (txt) rather than editing generated .rsc files directly
- **Deployment**: Generated .rsc files are imported into Mikrotik router via WinBox, WebFig, or SSH

## Common Commands Reference
```bash
# Quick validation of entire setup
ls -la allowed_sites.txt dns_servers.txt  # Check config files exist
./generate_config.sh                      # Generate RouterOS config
./validate_mikrotik.sh mikrotik_config.rsc # Validate generated config
shellcheck *.sh                          # Lint bash scripts

# View current configuration
cat allowed_sites.txt    # Show allowed websites
cat dns_servers.txt      # Show DNS servers
cat mikrotik_config.rsc  # Show generated RouterOS config

# Add new allowed site
echo "example.com" >> allowed_sites.txt

# Add new DNS server
echo "8.8.8.8" >> dns_servers.txt
```

## Time Expectations
- **Configuration file operations**: Instant (< 1 second)
- **Script generation**: Instant (< 1 second) 
- **Script validation**: Instant (< 1 second)
- **Shellcheck linting**: < 5 seconds
- **Complete validation workflow**: < 5 seconds
- **NEVER CANCEL**: Set timeouts to 30+ seconds for all operations to be safe

All operations are extremely fast. If any command takes more than 10 seconds, something is wrong and should be investigated.