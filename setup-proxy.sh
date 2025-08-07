#!/bin/bash

# Setup script for Apache proxy configuration for 2004scape server
# Run this script with sudo

echo "2004scape Apache Proxy Setup Script"
echo "==================================="
echo ""

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run this script with sudo: sudo ./setup-proxy.sh"
    exit 1
fi

echo "Enabling required Apache modules..."
a2enmod proxy proxy_http proxy_wstunnel rewrite headers

echo ""
echo "Copying configuration file..."
cp apache-proxy.conf /etc/apache2/sites-available/2004scape.conf

echo ""
echo "Disabling default site (if enabled)..."
a2dissite 000-default.conf 2>/dev/null || true

echo ""
echo "Enabling 2004scape site..."
a2ensite 2004scape

echo ""
echo "Testing Apache configuration..."
apache2ctl configtest

echo ""
echo "Reloading Apache..."
systemctl reload apache2

echo ""
echo "Setup complete!"
echo ""
echo "Your 2004scape server should now be accessible at:"
echo "  http://localhost/"
echo "  http://YOUR_IP_ADDRESS/"
echo ""
echo "The game server must be running on port 8888 for the proxy to work."
echo "Start it with: npm run dev"