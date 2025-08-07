#!/bin/bash

# 2004scape VPS Installer Script
# One-command installation for fresh VPS

set -e  # Exit on error

echo "============================================"
echo "       2004scape VPS Installer"
echo "============================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Get developer account information
echo "=== Developer Account Setup ==="
read -p "Enter developer username: " DEV_USERNAME
while true; do
    read -s -p "Enter developer password: " DEV_PASSWORD
    echo
    read -s -p "Confirm developer password: " DEV_PASSWORD_CONFIRM
    echo
    if [ "$DEV_PASSWORD" = "$DEV_PASSWORD_CONFIRM" ]; then
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done

echo ""
echo "=== Installing System Dependencies ==="

# Update package list
apt-get update

# Install required packages
apt-get install -y \
    curl \
    git \
    build-essential \
    apache2 \
    sqlite3 \
    python3 \
    screen

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install PM2 globally
npm install -g pm2

echo ""
echo "=== Cloning 2004scape Server ==="

# Clone the repository
cd /opt
git clone https://github.com/crucifix86/2004scape-server.git
cd 2004scape-server

echo ""
echo "=== Installing Node Dependencies ==="

# Install npm packages
npm install

echo ""
echo "=== Setting Up Database ==="

# Copy clean database
cp db_clean.sqlite db.sqlite

# Create a temporary script to hash the password after dependencies are installed
cat > hash_password.js << EOF
const bcrypt = require('bcryptjs');
const password = process.argv[2];
const hash = bcrypt.hashSync(password, 10);
console.log(hash);
EOF

# Hash the password using the temporary script
DEV_PASSWORD_HASH=$(node hash_password.js "$DEV_PASSWORD")

# Clean up temporary script
rm hash_password.js

# Insert developer account
sqlite3 db.sqlite "INSERT INTO account (username, password, staffmodlevel) VALUES ('$DEV_USERNAME', '$DEV_PASSWORD_HASH', 3);"

# Insert default settings
sqlite3 db.sqlite "
INSERT INTO settings (key, value) VALUES 
    ('server_name', '2004Scape'),
    ('auto_save', '300'),
    ('xp_rate', '1'),
    ('drop_rate', '1'),
    ('max_players', '2000'),
    ('starting_gold', '25'),
    ('shop_prices', 'normal'),
    ('allow_registration', 'true'),
    ('hiscores_update_interval', '5');
"

echo ""
echo "=== Configuring Apache Proxy ==="

# Enable required Apache modules
a2enmod proxy proxy_http proxy_wstunnel rewrite headers

# Create Apache configuration
cat > /etc/apache2/sites-available/2004scape.conf << 'EOF'
<VirtualHost *:80>
    ServerName localhost
    
    ProxyRequests Off
    ProxyPreserveHost On
    
    # Proxy all requests to Node.js server
    ProxyPass / http://localhost:8888/
    ProxyPassReverse / http://localhost:8888/
    
    # WebSocket support
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/?(.*) "ws://localhost:8888/$1" [P,L]
    
    # Headers
    <Location />
        Header set X-Forwarded-Proto "http"
    </Location>
    
    ErrorLog ${APACHE_LOG_DIR}/2004scape-error.log
    CustomLog ${APACHE_LOG_DIR}/2004scape-access.log combined
</VirtualHost>
EOF

# Disable default site and enable 2004scape
a2dissite 000-default.conf
a2ensite 2004scape

# Restart Apache
systemctl restart apache2

echo ""
echo "=== Building Game Server ==="

# Build the server
npm run build

echo ""
echo "=== Starting Login Server ==="

# Start login server in a separate process
screen -dmS login-server npm run login

# Wait for login server to start
echo "Waiting for login server to initialize..."
sleep 5

echo ""
echo "=== Starting Game Server with PM2 ==="

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: '2004scape',
    script: 'npm',
    args: 'run start',
    cwd: '/opt/2004scape-server',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '2G',
    env: {
      NODE_ENV: 'production'
    }
  }]
};
EOF

# Start the game server with PM2
pm2 start ecosystem.config.js

# Save PM2 process list and set up startup
pm2 save
pm2 startup systemd -u root --hp /root

echo ""
echo "=== Checking Services ==="

# Check if services are running
if systemctl is-active --quiet apache2; then
    echo "✓ Apache is running"
else
    echo "✗ Apache failed to start"
fi

if screen -list | grep -q "login-server"; then
    echo "✓ Login server is running"
else
    echo "✗ Login server failed to start"
fi

if pm2 list | grep -q "2004scape"; then
    echo "✓ Game server is running"
else
    echo "✗ Game server failed to start"
fi

echo ""
echo "============================================"
echo "       Installation Complete!"
echo "============================================"
echo ""
echo "Server URL: http://$(hostname -I | awk '{print $1}')"
echo "Developer account: $DEV_USERNAME"
echo ""
echo "Management commands:"
echo "  Game server logs: pm2 logs 2004scape"
echo "  Login server logs: screen -r login-server"
echo "  Restart game: pm2 restart 2004scape"
echo "  Stop all: pm2 stop all && screen -X -S login-server quit"
echo ""
echo "The server should now be accessible on port 80!"