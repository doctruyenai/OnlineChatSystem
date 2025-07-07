#!/bin/bash

# ==============================================================================
# HUONG DAN DEPLOY NHANH - FIXED VERSION
# Script huong dan deploy nhanh cho nguoi dung
# ==============================================================================

# Mau sac
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "============================================================================"
echo "                    HUONG DAN DEPLOY NHANH - 3 BUOC"
echo "============================================================================"
echo -e "${NC}"

echo -e "\n${GREEN}BUOC 1: CHUAN BI THONG TIN${NC}"
echo "Truoc khi bat dau, hay chuan bi:"
echo "• Domain name da tro ve IP VPS (vi du: chat.yoursite.com)"
echo "• Email de dang ky SSL certificate"
echo "• Mat khau database manh (it nhat 12 ky tu)"
echo "• Session secret (it nhat 32 ky tu ngau nhien)"

echo -e "\n${GREEN}BUOC 2: KIEM TRA HE THONG${NC}"
echo "Chay lenh sau de kiem tra VPS co du yeu cau:"
echo -e "${YELLOW}./check-requirements.sh${NC}"

echo -e "\n${GREEN}BUOC 3: DEPLOY NGAY${NC}"

echo -e "\n${BLUE}=== PHUONG PHAP 1: DEPLOY TU GITHUB (KHUYẾN NGHỊ) ===${NC}"
echo "Chi can 1 lenh tren VPS:"
echo -e "${YELLOW}curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github-fixed.sh | bash${NC}"

echo -e "\n${BLUE}=== PHUONG PHAP 2: DEPLOY TU LOCAL ===${NC}"
echo "Neu ban da tai code ve:"
echo -e "${YELLOW}./deploy-all-in-one.sh${NC}"

echo -e "\n${GREEN}SAU KHI HOAN THANH${NC}"
echo "• Website: https://yourdomain.com"
echo "• Admin Panel: https://yourdomain.com/auth"
echo "• Login: admin/admin123 (DOI NGAY!)"
echo "• Widget san sang tich hop"

echo -e "\n${GREEN}CAP NHAT SAU NAY${NC}"
echo -e "${YELLOW}sudo /usr/local/bin/chatapp-control.sh update${NC}"

echo -e "\n${RED}LUU Y QUAN TRONG${NC}"
echo "• Domain PHAI tro ve IP VPS truoc khi chay"
echo "• Doi mat khau admin ngay sau khi deploy"
echo "• Backup database thuong xuyen"

echo -e "\n${BLUE}============================================================================${NC}"
echo -e "${GREEN}SAN SANG DEPLOY? COPY VA PASTE LENH SAU:${NC}"
echo ""
echo -e "${YELLOW}curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github-fixed.sh | bash${NC}"
echo ""
echo -e "${BLUE}Thoi gian deploy: 25-35 phut${NC}"
echo -e "${BLUE}============================================================================${NC}"