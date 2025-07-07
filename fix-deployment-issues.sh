#!/bin/bash

# ==============================================================================
# SCRIPT SUA LOI DEPLOYMENT ISSUES
# Fix PM2, ecosystem.config.js va cac van de deployment
# ==============================================================================

# Mau sac
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

echo -e "${BLUE}"
echo "============================================================================"
echo "                    SUA LOI DEPLOYMENT ISSUES"
echo "============================================================================"
echo -e "${NC}"

# 1. Stop tat ca PM2 processes
log "Dung tat ca PM2 processes..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# 2. Kiem tra va sua ecosystem.config.js
log "Kiem tra ecosystem.config.js..."
if [[ ! -f "ecosystem.config.js" ]]; then
    log "Tao file ecosystem.config.js moi..."
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
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true,
    max_memory_restart: '1G',
    restart_delay: 4000,
    max_restarts: 10,
    min_uptime: '10s',
    watch: false,
    ignore_watch: [
      'node_modules',
      'logs',
      '.git'
    ]
  }]
}
EOF
fi

# 3. Tao thu muc logs
log "Tao thu muc logs..."
mkdir -p logs

# 4. Kiem tra va cai dependencies
log "Kiem tra dependencies..."
if [[ ! -d "node_modules" ]]; then
    log "Cai dat dependencies..."
    npm install
fi

# 5. Build ung dung
log "Build ung dung..."
npm run build

# 6. Kiem tra file build
if [[ ! -f "dist/index.js" ]]; then
    error "Build failed - khong co file dist/index.js"
    exit 1
fi

# 7. Test ecosystem.config.js
log "Test ecosystem.config.js syntax..."
node -c ecosystem.config.js
if [[ $? -ne 0 ]]; then
    error "ecosystem.config.js co loi syntax"
    exit 1
fi

# 8. Start ung dung voi PM2
log "Start ung dung voi PM2..."
pm2 start ecosystem.config.js --env production

# 9. Kiem tra status
log "Kiem tra PM2 status..."
pm2 status

# 10. Kiem tra logs
log "Kiem tra logs..."
sleep 5
pm2 logs --lines 10

# 11. Save PM2 config
log "Save PM2 configuration..."
pm2 save

echo -e "\n${GREEN}============================================================================"
echo "                    SUA LOI HOAN THANH!"
echo "============================================================================${NC}"

echo -e "\n${BLUE}KIEM TRA KET QUA:${NC}"
echo "1. PM2 status: pm2 status"
echo "2. Logs: pm2 logs"
echo "3. Website: curl -I http://localhost:3000"
echo "4. Restart: pm2 restart chat-system"