#!/bin/bash

# ==============================================================================
# SCRIPT KIỂM TRA YÊU CẦU HỆ THỐNG
# Kiểm tra VPS có đủ yêu cầu để chạy Real-time Chat System không
# ==============================================================================

# Màu sắc cho terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Biến đếm
PASSED=0
FAILED=0
WARNINGS=0

# Hàm logging
pass() {
    echo -e "${GREEN}✓ $1${NC}"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗ $1${NC}"
    ((FAILED++))
}

warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((WARNINGS++))
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

echo -e "${BLUE}"
echo "============================================================================"
echo "    KIỂM TRA YÊU CẦU HỆ THỐNG - REAL-TIME CHAT SYSTEM"
echo "============================================================================"
echo -e "${NC}"

# Kiểm tra hệ điều hành
echo -e "\n${BLUE}1. KIỂM TRA HỆ ĐIỀU HÀNH${NC}"
if grep -q "Ubuntu 20.04" /etc/os-release; then
    pass "Ubuntu 20.04 LTS"
elif grep -q "Ubuntu" /etc/os-release; then
    warn "Ubuntu $(grep VERSION_ID /etc/os-release | cut -d'"' -f2) - Khuyến nghị Ubuntu 20.04"
else
    fail "Không phải Ubuntu - Script được thiết kế cho Ubuntu 20.04"
fi

# Kiểm tra quyền sudo
echo -e "\n${BLUE}2. KIỂM TRA QUYỀN SUDO${NC}"
if sudo -n true 2>/dev/null; then
    pass "Có quyền sudo"
else
    fail "Không có quyền sudo - Cần thiết để cài đặt"
fi

# Kiểm tra RAM
echo -e "\n${BLUE}3. KIỂM TRA BỘ NHỚ RAM${NC}"
RAM_MB=$(free -m | awk 'NR==2{printf "%.0f", $2}')
if [ "$RAM_MB" -ge 4096 ]; then
    pass "RAM: ${RAM_MB}MB (Tuyệt vời)"
elif [ "$RAM_MB" -ge 2048 ]; then
    pass "RAM: ${RAM_MB}MB (Đủ yêu cầu)"
elif [ "$RAM_MB" -ge 1024 ]; then
    warn "RAM: ${RAM_MB}MB (Thấp, có thể chậm)"
else
    fail "RAM: ${RAM_MB}MB (Không đủ, cần tối thiểu 1GB)"
fi

# Kiểm tra CPU
echo -e "\n${BLUE}4. KIỂM TRA CPU${NC}"
CPU_CORES=$(nproc)
if [ "$CPU_CORES" -ge 4 ]; then
    pass "CPU: ${CPU_CORES} cores (Tuyệt vời)"
elif [ "$CPU_CORES" -ge 2 ]; then
    pass "CPU: ${CPU_CORES} cores (Đủ yêu cầu)"
else
    warn "CPU: ${CPU_CORES} core (Thấp, khuyến nghị 2+ cores)"
fi

# Kiểm tra dung lượng ổ cứng
echo -e "\n${BLUE}5. KIỂM TRA DUNG LƯỢNG Ổ CỨNG${NC}"
DISK_AVAILABLE=$(df / | awk 'NR==2 {print $4}')
DISK_AVAILABLE_GB=$((DISK_AVAILABLE / 1024 / 1024))
if [ "$DISK_AVAILABLE_GB" -ge 20 ]; then
    pass "Dung lượng trống: ${DISK_AVAILABLE_GB}GB (Đủ yêu cầu)"
elif [ "$DISK_AVAILABLE_GB" -ge 10 ]; then
    warn "Dung lượng trống: ${DISK_AVAILABLE_GB}GB (Ít, cần theo dõi)"
else
    fail "Dung lượng trống: ${DISK_AVAILABLE_GB}GB (Không đủ, cần tối thiểu 10GB)"
fi

# Kiểm tra kết nối internet
echo -e "\n${BLUE}6. KIỂM TRA KẾT NỐI INTERNET${NC}"
if ping -c 1 google.com >/dev/null 2>&1; then
    pass "Kết nối internet hoạt động"
else
    fail "Không có kết nối internet"
fi

# Kiểm tra port cần thiết
echo -e "\n${BLUE}7. KIỂM TRA PORTS${NC}"
PORTS_TO_CHECK=(80 443 3000 5432)
for port in "${PORTS_TO_CHECK[@]}"; do
    if ss -tuln | grep -q ":$port "; then
        warn "Port $port đang được sử dụng"
    else
        pass "Port $port có sẵn"
    fi
done

# Kiểm tra DNS resolution
echo -e "\n${BLUE}8. KIỂM TRA DNS${NC}"
if nslookup google.com >/dev/null 2>&1; then
    pass "DNS resolution hoạt động"
else
    fail "Lỗi DNS resolution"
fi

# Kiểm tra timezone
echo -e "\n${BLUE}9. KIỂM TRA TIMEZONE${NC}"
TIMEZONE=$(timedatectl | grep "Time zone" | awk '{print $3}')
info "Timezone hiện tại: $TIMEZONE"
if [[ "$TIMEZONE" == "Asia/Ho_Chi_Minh" || "$TIMEZONE" == "UTC" ]]; then
    pass "Timezone phù hợp"
else
    warn "Timezone không phải Asia/Ho_Chi_Minh hoặc UTC"
fi

# Kiểm tra software đã cài
echo -e "\n${BLUE}10. KIỂM TRA PHẦN MỀM ĐÃ CÀI${NC}"
SOFTWARE_CHECK=(curl wget git)
for software in "${SOFTWARE_CHECK[@]}"; do
    if command -v $software >/dev/null 2>&1; then
        pass "$software đã được cài đặt"
    else
        warn "$software chưa được cài đặt (sẽ được cài tự động)"
    fi
done

# Kiểm tra các dịch vụ xung đột
echo -e "\n${BLUE}11. KIỂM TRA XUNG ĐỘT DỊCH VỤ${NC}"
CONFLICTING_SERVICES=(apache2 mysql mariadb nginx nodejs postgresql)
for service in "${CONFLICTING_SERVICES[@]}"; do
    if systemctl is-active --quiet $service 2>/dev/null; then
        warn "$service đang chạy - có thể xung đột"
    else
        pass "$service không chạy"
    fi
done

# Kiểm tra firewall
echo -e "\n${BLUE}12. KIỂM TRA FIREWALL${NC}"
if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(ufw status | head -1)
    if [[ "$UFW_STATUS" == *"inactive"* ]]; then
        pass "UFW firewall tắt (sẽ được cấu hình)"
    else
        warn "UFW firewall đang hoạt động (cần kiểm tra rules)"
    fi
else
    warn "UFW chưa được cài đặt (sẽ được cài tự động)"
fi

# Kiểm tra package.json
echo -e "\n${BLUE}13. KIỂM TRA SOURCE CODE${NC}"
if [[ -f "package.json" ]]; then
    pass "package.json có sẵn"
    if [[ -f "deploy-all-in-one.sh" ]]; then
        pass "Script triển khai có sẵn"
    else
        fail "Không tìm thấy deploy-all-in-one.sh"
    fi
else
    fail "Không tìm thấy package.json - Vui lòng chạy từ thư mục source code"
fi

# Tổng kết
echo -e "\n${BLUE}============================================================================${NC}"
echo -e "${BLUE}                              TÓM TẮT KẾT QUẢ${NC}"
echo -e "${BLUE}============================================================================${NC}"

echo -e "${GREEN}✓ Đạt yêu cầu: $PASSED${NC}"
echo -e "${YELLOW}⚠ Cảnh báo: $WARNINGS${NC}"
echo -e "${RED}✗ Lỗi: $FAILED${NC}"

if [ "$FAILED" -eq 0 ]; then
    if [ "$WARNINGS" -eq 0 ]; then
        echo -e "\n${GREEN}🎉 HỆ THỐNG HOÀN HẢO! Sẵn sàng triển khai.${NC}"
        echo -e "${GREEN}Chạy lệnh: ./deploy-all-in-one.sh${NC}"
    else
        echo -e "\n${YELLOW}⚠️  HỆ THỐNG CÓ THỂ TRIỂN KHAI nhưng có một số cảnh báo.${NC}"
        echo -e "${YELLOW}Khuyến nghị xem xét các cảnh báo trước khi triển khai.${NC}"
        echo -e "\n${BLUE}Tiếp tục triển khai: ./deploy-all-in-one.sh${NC}"
    fi
else
    echo -e "\n${RED}❌ HỆ THỐNG CHƯA SẴN SÀNG! Cần khắc phục các lỗi trước.${NC}"
    echo -e "${RED}Vui lòng khắc phục các lỗi đỏ và chạy lại script kiểm tra.${NC}"
fi

echo -e "\n${BLUE}Ghi chú:${NC}"
echo -e "• Script này chỉ kiểm tra yêu cầu cơ bản"
echo -e "• Một số vấn đề sẽ được tự động khắc phục trong quá trình triển khai"
echo -e "• Đảm bảo domain name đã trỏ về IP VPS trước khi triển khai"

echo -e "\n${BLUE}============================================================================${NC}"