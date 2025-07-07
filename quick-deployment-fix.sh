#!/bin/bash

# ==============================================================================
# QUICK DEPLOYMENT FIX - SUA NGAY LOI DEPLOYMENT
# ==============================================================================

echo "=== SUA LOI DEPLOYMENT NHANH ==="

# 1. Stop development server
echo "1. Dung development server..."
pkill -f "npm run dev" 2>/dev/null || true
pkill -f "tsx server" 2>/dev/null || true

# 2. Build nhanh chi backend
echo "2. Build backend..."
npx esbuild server/index.ts --platform=node --packages=external --bundle --format=esm --outdir=dist --minify

# 3. Tao logs directory
mkdir -p logs

# 4. Sua ecosystem.config.js de don gian hon
echo "3. Sua ecosystem.config.js..."
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'chat-system',
    script: 'dist/index.js',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
}
EOF

# 5. Check PM2
if ! command -v pm2 &> /dev/null; then
    echo "4. Cai dat PM2..."
    npm install -g pm2
fi

# 6. Start app
echo "5. Start ung dung..."
pm2 delete chat-system 2>/dev/null || true
pm2 start ecosystem.config.js

# 7. Check status
echo "6. Kiem tra status..."
sleep 3
pm2 status
pm2 logs --lines 5

echo ""
echo "=== HOAN THANH ==="
echo "Kiem tra: curl http://localhost:3000"
echo "PM2 logs: pm2 logs"
echo "Restart: pm2 restart chat-system"