#!/bin/bash

# ==============================================================================
# REAL-TIME CHAT SYSTEM - DEPLOY TRỰC TIẾP TỪ GITHUB
# Deploy nhanh từ GitHub repository
# ==============================================================================

set -e  # Dừng script khi có lỗi

# Màu sắc cho terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub Repository mặc định
DEFAULT_GITHUB_REPO="https://github.com/doctruyenai/OnlineChatSystem"

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

echo -e "${BLUE}"
echo "============================================================================"
echo "        DEPLOY REAL-TIME CHAT SYSTEM TỪ GITHUB REPOSITORY"
echo "============================================================================"
echo -e "${NC}"

# Kiểm tra quyền root
if [[ $EUID -eq 0 ]]; then
    error "Script này không nên chạy với quyền root. Vui lòng chạy với user thường."
fi

# Kiểm tra hệ điều hành
if ! grep -q "Ubuntu" /etc/os-release; then
    warn "Script này được thiết kế cho Ubuntu. Có thể gặp vấn đề trên hệ điều hành khác."
    read -p "Bạn có muốn tiếp tục? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Thu thập thông tin
echo -e "\n${BLUE}==================== CẤU HÌNH TRIỂN KHAI ====================${NC}"

# GitHub Repository
echo -e "\n${YELLOW}GitHub Repository:${NC}"
echo "Repository mặc định: $DEFAULT_GITHUB_REPO"
read -p "Nhập GitHub Repository URL (Enter để dùng mặc định): " GITHUB_REPO

if [[ -z "$GITHUB_REPO" ]]; then
    GITHUB_REPO="$DEFAULT_GITHUB_REPO"
fi

log "Sẽ clone code từ: $GITHUB_REPO"

# Kiểm tra Git
if ! command -v git &> /dev/null; then
    log "Cài đặt Git..."
    sudo apt update
    sudo apt install -y git
fi

# Tạo thư mục tạm để clone
TEMP_DIR="/tmp/chat-deployment-$(date +%s)"
log "Tạo thư mục tạm: $TEMP_DIR"
mkdir -p $TEMP_DIR

# Clone repository
log "Clone repository từ GitHub..."
git clone $GITHUB_REPO $TEMP_DIR
if [[ $? -ne 0 ]]; then
    error "Không thể clone repository. Vui lòng kiểm tra URL và quyền truy cập."
fi

# Chuyển đến thư mục code
cd $TEMP_DIR

# Kiểm tra files deployment
if [[ ! -f "deploy-all-in-one.sh" ]]; then
    error "Không tìm thấy script deploy-all-in-one.sh trong repository."
fi

if [[ ! -f "package.json" ]]; then
    error "Không tìm thấy package.json trong repository."
fi

# Cấp quyền thực thi
log "Cấp quyền thực thi cho scripts..."
chmod +x *.sh 2>/dev/null || true

# Thiết lập biến môi trường cho GitHub repo
export GITHUB_REPO="$GITHUB_REPO"

log "Chuẩn bị deploy từ GitHub repository..."
echo -e "\n${GREEN}Repository đã được clone thành công!${NC}"
echo -e "Bây giờ sẽ chạy script deploy chính..."

# Chạy script deploy chính
echo -e "\n${BLUE}==================== BẮT ĐẦU DEPLOY ====================${NC}"
./deploy-all-in-one.sh

# Cleanup
log "Dọn dẹp thư mục tạm..."
rm -rf $TEMP_DIR

echo -e "\n${GREEN}============================================================================"
echo "                    DEPLOY HOÀN THÀNH!"
echo "============================================================================${NC}"