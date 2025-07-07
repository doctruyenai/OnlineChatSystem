#!/bin/bash

# ==============================================================================
# SCRIPT KIỂM TRA FILES DEPLOYMENT
# Đảm bảo tất cả files cần thiết đã sẵn sàng
# ==============================================================================

# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Đếm
TOTAL_FILES=0
MISSING_FILES=0
EXECUTABLE_FILES=0

echo -e "${BLUE}"
echo "============================================================================"
echo "                    KIỂM TRA FILES DEPLOYMENT"
echo "============================================================================"
echo -e "${NC}"

# Danh sách files cần thiết
REQUIRED_FILES=(
    "deploy-all-in-one.sh"
    "check-requirements.sh"
    "deployment.config.sh"
    "setup-deployment.sh"
    "HUONG_DAN_SU_DUNG_DEPLOY.md"
    "quick-deploy-guide.sh"
    "package.json"
    "server/index.ts"
    "shared/schema.ts"
    "drizzle.config.ts"
    "ecosystem.config.js"
    "public/widget.js"
    "public/widget.css"
)

# Danh sách files cần quyền thực thi
EXECUTABLE_SCRIPTS=(
    "deploy-all-in-one.sh"
    "check-requirements.sh"
    "deployment.config.sh"
    "setup-deployment.sh"
    "quick-deploy-guide.sh"
)

echo -e "\n${BLUE}1. KIỂM TRA FILES CẦN THIẾT${NC}"
for file in "${REQUIRED_FILES[@]}"; do
    ((TOTAL_FILES++))
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓ $file${NC}"
    else
        echo -e "${RED}✗ $file (thiếu)${NC}"
        ((MISSING_FILES++))
    fi
done

echo -e "\n${BLUE}2. KIỂM TRA QUYỀN THỰC THI${NC}"
for script in "${EXECUTABLE_SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        if [[ -x "$script" ]]; then
            echo -e "${GREEN}✓ $script (có quyền thực thi)${NC}"
            ((EXECUTABLE_FILES++))
        else
            echo -e "${YELLOW}⚠ $script (chưa có quyền thực thi)${NC}"
        fi
    fi
done

echo -e "\n${BLUE}3. KIỂM TRA CẤU TRÚC THƯ MỤC${NC}"
REQUIRED_DIRS=(
    "server"
    "client"
    "shared"
    "public"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}✓ $dir/${NC}"
    else
        echo -e "${RED}✗ $dir/ (thiếu)${NC}"
    fi
done

echo -e "\n${BLUE}4. KIỂM TRA FILES CẤU HÌNH${NC}"
CONFIG_FILES=(
    "package.json"
    "drizzle.config.ts"
    "ecosystem.config.js"
    "deployment.config.sh"
)

for config in "${CONFIG_FILES[@]}"; do
    if [[ -f "$config" ]]; then
        echo -e "${GREEN}✓ $config${NC}"
        
        # Kiểm tra nội dung cơ bản
        case "$config" in
            "package.json")
                if grep -q '"name"' "$config" && grep -q '"scripts"' "$config"; then
                    echo -e "  ${GREEN}→ Cấu trúc hợp lệ${NC}"
                else
                    echo -e "  ${YELLOW}→ Cấu trúc có thể thiếu sót${NC}"
                fi
                ;;
            "drizzle.config.ts")
                if grep -q "DATABASE_URL" "$config"; then
                    echo -e "  ${GREEN}→ Cấu hình database có${NC}"
                else
                    echo -e "  ${YELLOW}→ Cần kiểm tra cấu hình database${NC}"
                fi
                ;;
        esac
    else
        echo -e "${RED}✗ $config (thiếu)${NC}"
    fi
done

echo -e "\n${BLUE}5. TÓM TẮT KẾT QUẢ${NC}"
echo "================================================"
echo "Files kiểm tra: $TOTAL_FILES"
echo -e "Files thiếu: ${RED}$MISSING_FILES${NC}"
echo -e "Scripts có quyền thực thi: ${GREEN}$EXECUTABLE_FILES${NC}/${#EXECUTABLE_SCRIPTS[@]}"

if [[ $MISSING_FILES -eq 0 ]]; then
    echo -e "\n${GREEN}✅ TẤT CẢ FILES CẦN THIẾT ĐÃ SẴN SÀNG!${NC}"
    
    if [[ $EXECUTABLE_FILES -lt ${#EXECUTABLE_SCRIPTS[@]} ]]; then
        echo -e "\n${YELLOW}⚠️ CẦN CẤP QUYỀN THỰC THI:${NC}"
        echo "Chạy: chmod +x *.sh"
    fi
    
    echo -e "\n${BLUE}SẴN SÀNG DEPLOY!${NC}"
    echo "Bước tiếp theo:"
    echo "1. ./quick-deploy-guide.sh     # Xem hướng dẫn nhanh"
    echo "2. ./check-requirements.sh     # Kiểm tra VPS"
    echo "3. ./deploy-all-in-one.sh      # Triển khai"
    
else
    echo -e "\n${RED}❌ THIẾU MỘT SỐ FILES QUAN TRỌNG!${NC}"
    echo "Vui lòng kiểm tra và bổ sung các files thiếu trước khi deploy."
fi

echo -e "\n${BLUE}================================================${NC}"