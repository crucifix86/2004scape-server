# Apache Proxy Setup for 2004scape Server

This guide explains how to set up Apache as a reverse proxy for the 2004scape server, allowing it to be accessed on standard HTTP port 80 instead of port 8888.

## Prerequisites

- Apache2 installed and running
- sudo/root access to configure Apache

## Quick Setup

Run the provided setup script with sudo:

```bash
sudo ./setup-proxy.sh
```

## Manual Setup

If you prefer to set up manually or the script doesn't work:

1. **Enable required Apache modules:**
   ```bash
   sudo a2enmod proxy proxy_http proxy_wstunnel rewrite headers
   ```

2. **Copy the configuration file:**
   ```bash
   sudo cp apache-proxy.conf /etc/apache2/sites-available/2004scape.conf
   ```

3. **Enable the site:**
   ```bash
   sudo a2ensite 2004scape
   ```

4. **Disable the default site (optional):**
   ```bash
   sudo a2dissite 000-default.conf
   ```

5. **Test the configuration:**
   ```bash
   sudo apache2ctl configtest
   ```

6. **Reload Apache:**
   ```bash
   sudo systemctl reload apache2
   ```

## Accessing the Server

Once configured, you can access the server at:
- `http://localhost/` (from the same machine)
- `http://YOUR_IP_ADDRESS/` (from other devices on the network)

The game server must be running on port 8888 for the proxy to work.

## Troubleshooting

1. **Check if Apache is running:**
   ```bash
   systemctl status apache2
   ```

2. **Check Apache error logs:**
   ```bash
   sudo tail -f /var/log/apache2/error.log
   sudo tail -f /var/log/apache2/2004scape-error.log
   ```

3. **Make sure the game server is running on port 8888:**
   ```bash
   npm run dev
   ```

4. **Check if port 80 is already in use:**
   ```bash
   sudo netstat -tlnp | grep :80
   ```

## Firewall Configuration

If you have a firewall enabled, make sure port 80 is open:

```bash
sudo ufw allow 80/tcp
```

## SSL/HTTPS Setup (Optional)

To enable HTTPS, you'll need:
1. A domain name pointing to your server
2. An SSL certificate (you can get free ones from Let's Encrypt)
3. Additional Apache configuration

This is beyond the scope of this basic setup guide.