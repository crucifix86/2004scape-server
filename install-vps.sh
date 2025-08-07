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
    screen \
    unzip \
    rsync \
    openjdk-17-jre-headless

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
if ! npm install; then
    echo "Error: npm install failed"
    exit 1
fi

# Verify tsx is installed
if ! npx tsx --version > /dev/null 2>&1; then
    echo "Error: tsx not installed properly"
    exit 1
fi

echo ""
echo "=== Setting Up Database ==="

# Copy clean database
cp db_clean.sqlite db.sqlite

# Create a temporary CommonJS script to hash the password
cat > hash_password.cjs << EOF
const bcrypt = require('bcrypt');
const password = process.argv[2];
const hash = bcrypt.hashSync(password, 10);
console.log(hash);
EOF

# Hash the password using the temporary script
DEV_PASSWORD_HASH=$(node hash_password.cjs "$DEV_PASSWORD")

# Clean up temporary script
rm hash_password.cjs

# Insert developer account with full developer privileges (level 4)
sqlite3 db.sqlite "INSERT INTO account (username, password, staffmodlevel) VALUES ('$DEV_USERNAME', '$DEV_PASSWORD_HASH', 4);"

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
echo "=== Creating Environment Configuration ==="

# Create .env file with build verification disabled
cat > .env << 'EOF'
BUILD_VERIFY=false
EOF

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

# Create PM2 ecosystem file for dev mode
cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: '2004scape',
    script: 'npm',
    args: 'run dev',
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
pm2 start ecosystem.config.cjs

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
echo "=== Waiting for services to start ==="
sleep 10

echo ""
echo "=== Verifying Installation ==="

# Check if Node.js server is running on port 8888
if netstat -tuln | grep -q ":8888"; then
    echo "✓ Game server is listening on port 8888"
else
    echo "✗ Game server is NOT listening on port 8888"
    echo "  Check logs with: pm2 logs 2004scape"
fi

# Test the backend directly
echo ""
echo "Testing backend server..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8888 | grep -q "200"; then
    echo "✓ Backend server responds correctly"
else
    echo "✗ Backend server not responding"
    echo "  HTTP Status: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8888)"
fi

# Check Apache error log
echo ""
echo "Recent Apache errors:"
tail -5 /var/log/apache2/2004scape-error.log 2>/dev/null || echo "No errors found"

echo ""
echo "============================================"
echo "       Installation Complete!"
echo "============================================"
echo ""
echo "Server URL: http://$(hostname -I | awk '{print $1}')"
echo "Developer account: $DEV_USERNAME"
echo ""
echo "Troubleshooting commands:"
echo "  Game server status: pm2 status"
echo "  Game server logs: pm2 logs 2004scape"
echo "  Login server logs: screen -r login-server"
echo "  Apache errors: tail -f /var/log/apache2/2004scape-error.log"
echo "  Check ports: netstat -tuln | grep -E '8888|80|43500'"
echo "  Restart game: pm2 restart 2004scape"
echo "  Restart all: pm2 restart all && systemctl restart apache2"
echo ""
echo "If you see 503 errors, the game server may still be starting up."
echo "Wait a minute and refresh the page."