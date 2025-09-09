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

# Create the landing page content
:local htmlContent "<!DOCTYPE html>
<html>
<head>
    <title>Safe Cycling - Allowed Websites</title>
    <meta charset=\"UTF-8\">
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f0f8ff; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h1 { color: #2c5aa0; text-align: center; }
        h2 { color: #1e3d72; border-bottom: 2px solid #2c5aa0; padding-bottom: 5px; }
        .warning { background-color: #fff3cd; border: 1px solid #ffeaa7; color: #856404; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .allowed-sites { background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; border-radius: 5px; }
        ul { list-style-type: none; padding: 0; }
        li { margin: 10px 0; padding: 10px; background-color: #f8f9fa; border-left: 4px solid #2c5aa0; }
        a { color: #2c5aa0; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .footer { text-align: center; margin-top: 30px; font-size: 12px; color: #666; }
    </style>
</head>
<body>
    <div class=\"container\">
        <h1>🚴 Safe Cycling Network 🚴</h1>
        
        <div class=\"warning\">
            <strong>⚠️ NOTICE:</strong> This network is configured for safe and educational browsing only. 
            Access is restricted to approved websites listed below.
        </div>
        
        <h2>📋 Allowed Websites</h2>
        <div class=\"allowed-sites\">
            <p><strong>The following websites are accessible on this network:</strong></p>
            <ul>
                <li>📚 <a href=\"https://en.wikipedia.org\" target=\"_blank\">Wikipedia (English)</a> - Free encyclopedia</li>
                <li>📚 <a href=\"https://www.wikipedia.org\" target=\"_blank\">Wikipedia (Main)</a> - Free encyclopedia</li>
                <li>💻 <a href=\"https://github.com\" target=\"_blank\">GitHub</a> - Code repositories and collaboration</li>
                <li>❓ <a href=\"https://stackoverflow.com\" target=\"_blank\">Stack Overflow</a> - Programming Q&A</li>
                <li>📖 <a href=\"https://developer.mozilla.org\" target=\"_blank\">MDN Web Docs</a> - Web development documentation</li>
                <li>🎓 <a href=\"https://w3schools.com\" target=\"_blank\">W3Schools</a> - Web development tutorials</li>
                <li>💡 <a href=\"https://codecademy.com\" target=\"_blank\">Codecademy</a> - Interactive coding lessons</li>
                <li>🎓 <a href=\"https://khanacademy.org\" target=\"_blank\">Khan Academy</a> - Free educational content</li>
                <li>📚 <a href=\"https://coursera.org\" target=\"_blank\">Coursera</a> - Online courses</li>
                <li>🎓 <a href=\"https://edx.org\" target=\"_blank\">edX</a> - University-level online courses</li>
            </ul>
        </div>
        
        <h2>🔒 Security Features</h2>
        <ul>
            <li>🛡️ All DNS queries are monitored and filtered</li>
            <li>🚫 DNS over HTTPS (DoH) and DNS over TLS (DoT) are blocked</li>
            <li>🔐 VPN connection ensures secure browsing</li>
            <li>🚧 All other websites are blocked for safety</li>
        </ul>
        
        <div class=\"footer\">
            <p>Safe Cycling Network • Powered by MikroTik RouterOS v7</p>
            <p>For technical support or to request additional websites, contact your network administrator.</p>
        </div>
    </div>
</body>
</html>"

# Note: Due to MikroTik scripting limitations, the HTML content above needs to be 
# manually copied to the hotspot/index.html file in the router's file system

:log info "Landing page template created"
:log info "HTML content needs to be manually uploaded to /hotspot/index.html"
:log info "Web server enabled on port 80"