#!/bin/bash

# ==============================================================================
# SCRIPT KIEM TRA TRANG THAI DEPLOYMENT
# Kiem tra tat ca services va hien thi status
# ==============================================================================

# Mau sac
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "============================================================================"
echo "                    KIEM TRA TRANG THAI DEPLOYMENT"
echo "============================================================================"
echo -e "${NC}"

# 1. Kiem tra PM2
echo -e "\n${BLUE}=== PM2 STATUS ===${NC}"
if command -v pm2 &> /dev/null; then
    pm2 status
    echo -e "\n${BLUE}PM2 LOGS (10 dong cuoi):${NC}"
    pm2 logs --lines 10 2>/dev/null || echo "Khong co logs"
else
    echo -e "${RED}PM2 chua duoc cai dat${NC}"
fi

# 2. Kiem tra Node.js app
echo -e "\n${BLUE}=== APPLICATION STATUS ===${NC}"
if [[ -f "dist/index.js" ]]; then
    echo -e "${GREEN}✓ Build file ton tai: dist/index.js${NC}"
else
    echo -e "${RED}✗ Build file khong ton tai: dist/index.js${NC}"
fi

if [[ -f "package.json" ]]; then
    echo -e "${GREEN}✓ package.json ton tai${NC}"
else
    echo -e "${RED}✗ package.json khong ton tai${NC}"
fi

if [[ -f "ecosystem.config.js" ]]; then
    echo -e "${GREEN}✓ ecosystem.config.js ton tai${NC}"
    # Test syntax
    if node -c ecosystem.config.js 2>/dev/null; then
        echo -e "${GREEN}✓ ecosystem.config.js syntax dung${NC}"
    else
        echo -e "${RED}✗ ecosystem.config.js co loi syntax${NC}"
    fi
else
    echo -e "${RED}✗ ecosystem.config.js khong ton tai${NC}"
fi

# 3. Kiem tra HTTP response
echo -e "\n${BLUE}=== HTTP RESPONSE TEST ===${NC}"
if curl -s -I http://localhost:3000 >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Website dang hoat dong tren port 3000${NC}"
    curl -I http://localhost:3000 2>/dev/null | head -1
else
    echo -e "${RED}✗ Website khong phan hoi tren port 3000${NC}"
fi

# 4. Kiem tra processes
echo -e "\n${BLUE}=== RUNNING PROCESSES ===${NC}"
echo "Node.js processes:"
ps aux | grep -E "(node|npm)" | grep -v grep || echo "Khong co process Node.js"

# 5. Kiem tra ports
echo -e "\n${BLUE}=== PORT STATUS ===${NC}"
echo "Port 3000:"
if netstat -tulpn 2>/dev/null | grep -q ":3000 "; then
    echo -e "${GREEN}✓ Port 3000 dang duoc su dung${NC}"
    netstat -tulpn 2>/dev/null | grep ":3000 "
else
    echo -e "${RED}✗ Port 3000 khong duoc su dung${NC}"
fi

# 6. Kiem tra logs
echo -e "\n${BLUE}=== LOG FILES ===${NC}"
if [[ -d "logs" ]]; then
    echo -e "${GREEN}✓ Thu muc logs ton tai${NC}"
    ls -la logs/ 2>/dev/null || echo "Thu muc logs trong"
else
    echo -e "${RED}✗ Thu muc logs khong ton tai${NC}"
fi

# 7. Kiem tra environment
echo -e "\n${BLUE}=== ENVIRONMENT ===${NC}"
if [[ -f ".env" ]]; then
    echo -e "${GREEN}✓ File .env ton tai${NC}"
else
    echo -e "${YELLOW}! File .env khong ton tai${NC}"
fi

echo "NODE_ENV: ${NODE_ENV:-'chua set'}"
echo "PORT: ${PORT:-'chua set'}"

echo -e "\n${BLUE}============================================================================${NC}"
echo -e "${YELLOW}Neu can sua loi, chay: ./fix-deployment-issues.sh${NC}"
echo -e "${BLUE}============================================================================${NC}"