#!/bin/bash

# ==============================================================================
# HUONG DAN NHANH DEPLOY - 5 PHUT
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
echo "                    HUONG DAN DEPLOY NHANH - 5 BUOC"
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

echo -e "\n${GREEN}BUOC 3: (TUY CHON) TUYI CHINH CAU HINH${NC}"
echo "Neu muon thay doi cau hinh mac dinh:"
echo -e "${YELLOW}nano deployment.config.sh${NC}      # Chinh sua"
echo -e "${YELLOW}./deployment.config.sh show${NC}     # Xem cau hinh"

echo -e "\n${GREEN}BUOC 4: CHAY DEPLOY${NC}"
echo "Chay lenh trien khai chinh:"
echo -e "${YELLOW}./deploy-all-in-one.sh${NC}"
echo ""
echo "Script se hoi cac thong tin can thiet va tu dong cai dat."
echo "Thoi gian: 20-35 phut"

echo -e "\n${GREEN}BUOC 5: KIEM TRA KET QUA${NC}"
echo "Sau khi hoan thanh, truy cap:"
echo "• Website: https://yourdomain.com"
echo "• Admin: https://yourdomain.com/auth"
echo "• Dang nhap: admin/admin123 (DOI MAT KHAU NGAY!)"

echo -e "\n${BLUE}LENH NHANH:${NC}"
echo -e "${YELLOW}./check-requirements.sh && ./deploy-all-in-one.sh${NC}"

echo -e "\n${RED}LUU Y QUAN TRONG:${NC}"
echo "• Domain PHAI tro ve IP VPS truoc khi chay"
echo "• Doi mat khau admin ngay sau khi deploy"
echo "• Backup database thuong xuyen"

echo -e "\n${BLUE}HO TRO:${NC}"
echo "• Huong dan chi tiet: HUONG_DAN_SU_DUNG_DEPLOY.md"
echo "• Xem logs loi: tail -f deploy.log"
echo "• Kiem tra status: sudo systemctl status nginx postgresql"

echo -e "\n${GREEN}San sang deploy? Chay: ${YELLOW}./deploy-all-in-one.sh${NC}"