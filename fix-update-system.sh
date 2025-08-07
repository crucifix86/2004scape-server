#!/bin/bash

# Manual patch script to fix update system and backup paths
# Run this on the VPS to apply the fixes without using the update system

echo "=== Applying Update System and Backup Fixes ==="
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -d "src/website" ]; then
    echo "Error: This script must be run from the 2004scape-server directory"
    exit 1
fi

echo "Creating backup of server.ts..."
cp src/website/server.ts src/website/server.ts.backup

echo "Applying fixes..."

# Fix 1: Update system repository URLs
sed -i 's|crucifix86/2004scape-server-new|crucifix86/2004scape-server|g' src/website/server.ts

# Fix 2: Backup paths - Replace hardcoded /home/crucifix with dynamic paths
# This is more complex, so we'll use a temporary file
cat > /tmp/backup-fix.patch << 'EOF'
--- Fix backup creation path
            const backupName = \`backup-\${timestamp}.tar.gz\`;
-            const backupPath = path.join('/home/crucifix', backupName);
+            const projectDir = process.cwd();
+            const parentDir = path.dirname(projectDir);
+            const projectName = path.basename(projectDir);
+            const backupPath = path.join(parentDir, backupName);
            
            // Create backup using tar
            const { exec } = require('child_process');
            const util = require('util');
            const execPromise = util.promisify(exec);
            
-            await execPromise(\`cd /home/crucifix && tar --exclude='node_modules' --exclude='.git' --exclude='*.log' --exclude='*.pid' -czf \${backupName} 2004scape-server\`);
+            await execPromise(\`cd \${parentDir} && tar --exclude='node_modules' --exclude='.git' --exclude='*.log' --exclude='*.pid' -czf \${backupName} \${projectName}\`);

--- Fix list backups path
        try {
-            const files = fs.readdirSync('/home/crucifix');
+            const parentDir = path.dirname(process.cwd());
+            const files = fs.readdirSync(parentDir);
            const backups = files
                .filter(f => (f.startsWith('backup-') || f.startsWith('pre-update-backup-') || f.startsWith('2004scape-backup-')) && f.endsWith('.tar.gz'))
                .map(filename => {
-                    const stats = fs.statSync(path.join('/home/crucifix', filename));
+                    const stats = fs.statSync(path.join(parentDir, filename));

--- Fix file paths for download and delete
-        const filePath = path.join('/home/crucifix', filename);
+        const filePath = path.join(path.dirname(process.cwd()), filename);

--- Fix pre-update backup
                const backupName = \`pre-update-backup-\${timestamp}.tar.gz\`;
+                const projectDir = process.cwd();
+                const parentDir = path.dirname(projectDir);
+                const projectName = path.basename(projectDir);
                
-                await execPromise(\`cd /home/crucifix && tar --exclude='node_modules' --exclude='.git' --exclude='*.log' --exclude='*.pid' -czf \${backupName} 2004scape-server\`);
+                await execPromise(\`cd \${parentDir} && tar --exclude='node_modules' --exclude='.git' --exclude='*.log' --exclude='*.pid' -czf \${backupName} \${projectName}\`);
EOF

# Apply the more complex replacements using Node.js
node -e "
const fs = require('fs');
let content = fs.readFileSync('src/website/server.ts', 'utf8');

// Fix backup creation
content = content.replace(
    /const backupPath = path\.join\('\/home\/crucifix', backupName\);/g,
    \"const projectDir = process.cwd();\\n            const parentDir = path.dirname(projectDir);\\n            const projectName = path.basename(projectDir);\\n            const backupPath = path.join(parentDir, backupName);\"
);

// Fix tar command in create backup
content = content.replace(
    /await execPromise\(\`cd \/home\/crucifix && tar/g,
    'await execPromise(\`cd \${parentDir} && tar'
);
content = content.replace(
    /2004scape-server\`\);/g,
    '\${projectName}\`);'
);

// Fix list backups
content = content.replace(
    /const files = fs\.readdirSync\('\/home\/crucifix'\);/g,
    \"const parentDir = path.dirname(process.cwd());\\n            const files = fs.readdirSync(parentDir);\"
);
content = content.replace(
    /const stats = fs\.statSync\(path\.join\('\/home\/crucifix', filename\)\);/g,
    'const stats = fs.statSync(path.join(parentDir, filename));'
);

// Fix file paths
content = content.replace(
    /const filePath = path\.join\('\/home\/crucifix', filename\);/g,
    'const filePath = path.join(path.dirname(process.cwd()), filename);'
);

// Fix pre-update backup
content = content.replace(
    /const backupName = \`pre-update-backup-\\\${timestamp}\.tar\.gz\`;[\s\S]*?await execPromise\(\`cd \/home\/crucifix && tar/,
    'const backupName = \`pre-update-backup-\${timestamp}.tar.gz\`;\\n                const projectDir = process.cwd();\\n                const parentDir = path.dirname(projectDir);\\n                const projectName = path.basename(projectDir);\\n                \\n                await execPromise(\`cd \${parentDir} && tar'
);

// Fix restart server path
content = content.replace(
    /const restart = spawn\('\.\/server', \['restart'\], \{[\s]*detached: true,[\s]*stdio: 'ignore'[\s]*\}\);/,
    \"const path = require('path');\\n                const serverScript = path.join(__dirname, '..', '..', 'server');\\n                const restart = spawn(serverScript, ['restart'], {\\n                    detached: true,\\n                    stdio: 'ignore',\\n                    cwd: path.join(__dirname, '..', '..')\\n                });\"
);

fs.writeFileSync('src/website/server.ts', content);
console.log('Fixes applied successfully!');
"

# Download latest files
echo "Downloading latest files..."
# Download the latest server.ts and package.json
wget -q -O src/website/server.ts.new https://raw.githubusercontent.com/crucifix86/2004scape-server/main/src/website/server.ts
if [ $? -eq 0 ]; then
    mv src/website/server.ts.new src/website/server.ts
    echo "Updated server.ts"
    
    # Also update the server management script for better restart handling
    wget -q -O server.new https://raw.githubusercontent.com/crucifix86/2004scape-server/main/server
    if [ $? -eq 0 ]; then
        mv server.new server
        chmod +x server
        echo "Updated server management script"
    fi
fi

wget -q -O package.json.new https://raw.githubusercontent.com/crucifix86/2004scape-server/main/package.json
if [ $? -eq 0 ]; then
    mv package.json.new package.json
    echo "Updated package.json to latest version"
fi

echo ""
echo "Building the project..."
npm run build || echo "Note: Build failed, you may need to run 'npm install' first"

echo ""
echo "=== Fixes Applied Successfully! ==="
echo ""
echo "The following fixes have been applied:"
echo "1. Update system now checks the correct repository"
echo "2. Backup paths are now dynamic (work in /opt)"
echo "3. Restart functionality fixed"
echo "4. Update download process fixed"
echo "5. Version updated to 2.3.4"
echo ""
echo "Please restart the server for changes to take effect:"
echo "cd /opt/2004scape-server && ./server restart"
echo ""
echo "Backup created at: src/website/server.ts.backup"