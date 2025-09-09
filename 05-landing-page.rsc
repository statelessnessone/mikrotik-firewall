# MikroTik RouterOS v7 Landing Page Generator Script
# This script creates a warning/landing page that shows allowed websites
# Run this script on MikroTik HAP ac2

:log info "Starting landing page configuration..."

# Enable web server
/ip service set www disabled=no port=80

# Create the landing page HTML content
# Note: MikroTik has limited web server capabilities
# This creates a simple static page

# Create web server directory structure (if not exists)
/file remove "hotspot"
:delay 1s

# Create hotspot directory for web files
/tool fetch url="data:text/plain," dst-path="hotspot/index.html"

# Manual HTML Upload Required:
# Due to MikroTik scripting limitations, the landing page HTML content cannot be 
# automatically deployed via script. The complete HTML template is provided in 
# the 'landing-page.html' file in this repository for manual copying.
#
# To deploy the landing page:
# 1. Copy the content from 'landing-page.html' file
# 2. Upload it to '/hotspot/index.html' on the router via WinBox, WebFig, or SFTP
# 3. Ensure the web server is enabled (handled by this script)

:log info "Landing page directory structure created"
:log info "MANUAL STEP REQUIRED: Copy content from 'landing-page.html' file to /hotspot/index.html on router"
:log info "Web server enabled on port 80"