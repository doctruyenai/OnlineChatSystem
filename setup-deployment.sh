#!/bin/bash

# ==============================================================================
# SCRIPT SETUP TRIỂN KHAI - REAL-TIME CHAT SYSTEM
# Chuẩn bị và hướng dẫn triển khai
# ==============================================================================

# Màu sắc cho terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "============================================================================"
echo "    SETUP TRIỂN KHAI REAL-TIME CHAT SYSTEM"
echo "    Chuẩn bị scripts và hướng dẫn sử dụng"
echo "============================================================================"
echo -e "${NC}"

# Cấp quyền thực thi cho tất cả scripts
echo -e "\n${BLUE}1. Cấp quyền thực thi cho scripts...${NC}"
chmod +x deploy-all-in-one.sh
chmod +x check-requirements.sh
chmod +x deployment.config.sh
echo -e "${GREEN}✓ Đã cấp quyền thực thi${NC}"

# Kiểm tra files cần thiết
echo -e "\n${BLUE}2. Kiểm tra files cần thiết...${NC}"
REQUIRED_FILES=(
    "package.json"
    "deploy-all-in-one.sh"
    "check-requirements.sh"
    "deployment.config.sh"
    "README_DEPLOYMENT.md"
    "HUONG_DAN_TRIEN_KHAI.md"
)

ALL_GOOD=true
for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓ $file${NC}"
    else
        echo -e "${RED}✗ $file (thiếu)${NC}"
        ALL_GOOD=false
    fi
done

if ! $ALL_GOOD; then
    echo -e "\n${RED}❌ Thiếu một số files quan trọng. Vui lòng kiểm tra lại.${NC}"
    exit 1
fi

# Hiển thị hướng dẫn sử dụng
echo -e "\n${BLUE}3. Hướng dẫn sử dụng:${NC}"
echo -e "\n${YELLOW}BƯỚC 1: Kiểm tra yêu cầu hệ thống${NC}"
echo -e "   ./check-requirements.sh"

echo -e "\n${YELLOW}BƯỚC 2: (Tùy chọn) Tùy chỉnh cấu hình${NC}"
echo -e "   nano deployment.config.sh    # Chỉnh sửa cấu hình nếu cần"
echo -e "   ./deployment.config.sh show   # Xem cấu hình hiện tại"

echo -e "\n${YELLOW}BƯỚC 3: Triển khai hệ thống${NC}"
echo -e "   ./deploy-all-in-one.sh"

echo -e "\n${BLUE}4. Tài liệu hỗ trợ:${NC}"
echo -e "   • README_DEPLOYMENT.md      - Hướng dẫn nhanh"
echo -e "   • HUONG_DAN_TRIEN_KHAI.md   - Hướng dẫn chi tiết"

# Kiểm tra môi trường hiện tại
echo -e "\n${BLUE}5. Kiểm tra môi trường hiện tại:${NC}"
echo -e "   Hệ điều hành: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2 2>/dev/null || echo 'Không xác định')"
echo -e "   Người dùng: $(whoami)"
echo -e "   Thư mục: $(pwd)"
echo -e "   Quyền sudo: $(sudo -n true 2>/dev/null && echo 'Có' || echo 'Không')"

# Tạo shortcut commands
echo -e "\n${BLUE}6. Tạo các lệnh shortcut...${NC}"
cat > run-check.sh << 'EOF'
#!/bin/bash
echo "Kiểm tra yêu cầu hệ thống..."
./check-requirements.sh
EOF

cat > run-deploy.sh << 'EOF'
#!/bin/bash
echo "Bắt đầu triển khai..."
./deploy-all-in-one.sh
EOF

chmod +x run-check.sh run-deploy.sh
echo -e "${GREEN}✓ Đã tạo run-check.sh và run-deploy.sh${NC}"

echo -e "\n${GREEN}============================================================================"
echo "    SETUP HOÀN THÀNH - SẴN SÀNG TRIỂN KHAI!"
echo "============================================================================${NC}"

echo -e "\n${BLUE}Lệnh nhanh:${NC}"
echo -e "   ${YELLOW}./run-check.sh${NC}   - Kiểm tra hệ thống"
echo -e "   ${YELLOW}./run-deploy.sh${NC}  - Triển khai ngay"

echo -e "\n${BLUE}Hoặc từng bước:${NC}"
echo -e "   1. ./check-requirements.sh"
echo -e "   2. ./deploy-all-in-one.sh"

echo -e "\n${YELLOW}⚠️  Lưu ý quan trọng:${NC}"
echo -e "   • Đảm bảo domain đã trỏ về IP VPS"
echo -e "   • Chuẩn bị email để đăng ký SSL certificate"
echo -e "   • Tạo mật khẩu mạnh cho database"
echo -e "   • Không chạy với quyền root (sudo)"

echo -e "\n${GREEN}Chúc bạn triển khai thành công! 🚀${NC}"