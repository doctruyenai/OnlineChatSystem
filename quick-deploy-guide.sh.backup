#!/bin/bash

# ==============================================================================
# HƯỚNG DẪN NHANH DEPLOY - 5 PHÚT
# Script hướng dẫn deploy nhanh cho người dùng
# ==============================================================================

# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "============================================================================"
echo "                    HƯỚNG DẪN DEPLOY NHANH - 5 BƯỚC"
echo "============================================================================"
echo -e "${NC}"

echo -e "\n${GREEN}BƯỚC 1: CHUẨN BỊ THÔNG TIN${NC}"
echo "Trước khi bắt đầu, hãy chuẩn bị:"
echo "• Domain name đã trỏ về IP VPS (ví dụ: chat.yoursite.com)"
echo "• Email để đăng ký SSL certificate"
echo "• Mật khẩu database mạnh (ít nhất 12 ký tự)"
echo "• Session secret (ít nhất 32 ký tự ngẫu nhiên)"

echo -e "\n${GREEN}BƯỚC 2: KIỂM TRA HỆ THỐNG${NC}"
echo "Chạy lệnh sau để kiểm tra VPS có đủ yêu cầu:"
echo -e "${YELLOW}./check-requirements.sh${NC}"

echo -e "\n${GREEN}BƯỚC 3: (TÙY CHỌN) TÙYI CHỈNH CẤU HÌNH${NC}"
echo "Nếu muốn thay đổi cấu hình mặc định:"
echo -e "${YELLOW}nano deployment.config.sh${NC}      # Chỉnh sửa"
echo -e "${YELLOW}./deployment.config.sh show${NC}     # Xem cấu hình"

echo -e "\n${GREEN}BƯỚC 4: CHẠY DEPLOY${NC}"
echo "Chạy lệnh triển khai chính:"
echo -e "${YELLOW}./deploy-all-in-one.sh${NC}"
echo ""
echo "Script sẽ hỏi các thông tin cần thiết và tự động cài đặt."
echo "Thời gian: 20-35 phút"

echo -e "\n${GREEN}BƯỚC 5: KIỂM TRA KẾT QUẢ${NC}"
echo "Sau khi hoàn thành, truy cập:"
echo "• Website: https://yourdomain.com"
echo "• Admin: https://yourdomain.com/auth"
echo "• Đăng nhập: admin/admin123 (ĐỔI MẬT KHẨU NGAY!)"

echo -e "\n${BLUE}LỆNH NHANH:${NC}"
echo -e "${YELLOW}./check-requirements.sh && ./deploy-all-in-one.sh${NC}"

echo -e "\n${RED}LƯU Ý QUAN TRỌNG:${NC}"
echo "• Domain PHẢI trỏ về IP VPS trước khi chạy"
echo "• Đổi mật khẩu admin ngay sau khi deploy"
echo "• Backup database thường xuyên"

echo -e "\n${BLUE}HỖ TRỢ:${NC}"
echo "• Hướng dẫn chi tiết: HUONG_DAN_SU_DUNG_DEPLOY.md"
echo "• Xem logs lỗi: tail -f deploy.log"
echo "• Kiểm tra status: sudo systemctl status nginx postgresql"

echo -e "\n${GREEN}Sẵn sàng deploy? Chạy: ${YELLOW}./deploy-all-in-one.sh${NC}"