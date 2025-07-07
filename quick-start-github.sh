#!/bin/bash

# ==============================================================================
# QUICK START - DEPLOY TU GITHUB
# Huong dan nhanh deploy tu GitHub repository
# ==============================================================================

# Mau sac
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "============================================================================"
echo "              DEPLOY REAL-TIME CHAT SYSTEM TU GITHUB"
echo "                         HUONG DAN NHANH"
echo "============================================================================"
echo -e "${NC}"

echo -e "\n${GREEN}🚀 DEPLOY NHANH NHAT (1 LENH):${NC}"
echo -e "${YELLOW}curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github.sh | bash${NC}"

echo -e "\n${GREEN}📋 CHUAN BI TRUOC KHI CHAY:${NC}"
echo "✅ VPS Ubuntu 20.04+ voi quyen sudo"
echo "✅ Domain da tro ve IP VPS (quan trong!)"
echo "✅ Email cho SSL certificate"
echo "✅ Database password manh (12+ ky tu)"
echo "✅ Session secret (32+ ky tu ngau nhien)"

echo -e "\n${GREEN}⚡ QUY TRINH TU DONG:${NC}"
echo "1. Clone code tu GitHub: https://github.com/doctruyenai/OnlineChatSystem"
echo "2. Cai dat Node.js, PostgreSQL, Nginx, PM2"
echo "3. Build va deploy ung dung"
echo "4. Cau hinh SSL certificate tu dong"
echo "5. Thiet lap firewall va backup"

echo -e "\n${GREEN}🎯 KET QUA SAU DEPLOY:${NC}"
echo "• Website: https://yourdomain.com"
echo "• Admin Panel: https://yourdomain.com/auth"
echo "• Login: admin/admin123 (DOI NGAY!)"
echo "• Widget san sang tich hop"

echo -e "\n${GREEN}🔄 UPDATE SAU NAY:${NC}"
echo -e "${YELLOW}sudo /usr/local/bin/chatapp-control.sh update${NC}"

echo -e "\n${GREEN}📚 TAI LIEU HUONG DAN:${NC}"
echo "• HUONG_DAN_DEPLOY_TU_GITHUB.md - Chi tiet deploy tu GitHub"
echo "• HUONG_DAN_SU_DUNG_DEPLOY.md - Huong dan day du"
echo "• SUMMARY_DEPLOYMENT.md - Tom tat toan bo"

echo -e "\n${BLUE}============================================================================${NC}"
echo -e "${GREEN}SAN SANG DEPLOY? COPY VA PASTE LENH SAU:${NC}"
echo ""
echo -e "${YELLOW}curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github.sh | bash${NC}"
echo ""
echo -e "${BLUE}Thoi gian deploy: 25-35 phut${NC}"
echo -e "${BLUE}============================================================================${NC}"