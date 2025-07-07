#!/bin/bash

# ==============================================================================
# REAL-TIME CHAT SYSTEM - DEPLOY TRUC TIEP TU GITHUB
# Deploy nhanh tu GitHub repository - FIXED VERSION
# ==============================================================================

set -e  # Dung script khi co loi

# Mau sac cho terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub Repository mac dinh
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
echo "        DEPLOY REAL-TIME CHAT SYSTEM TU GITHUB REPOSITORY"
echo "============================================================================"
echo -e "${NC}"

# Kiem tra quyen root
if [[ $EUID -eq 0 ]]; then
    error "Script nay khong nen chay voi quyen root. Vui long chay voi user thuong."
fi

# Kiem tra he dieu hanh
if ! grep -q "Ubuntu" /etc/os-release; then
    warn "Script nay duoc thiet ke cho Ubuntu. Co the gap van de tren he dieu hanh khac."
    read -p "Ban co muon tiep tuc? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Thu thap thong tin
echo -e "\n${BLUE}==================== CAU HINH TRIEN KHAI ====================${NC}"

# GitHub Repository
echo -e "\n${YELLOW}GitHub Repository:${NC}"
echo "Repository mac dinh: $DEFAULT_GITHUB_REPO"
read -p "Nhap GitHub Repository URL (Enter de dung mac dinh): " GITHUB_REPO

if [[ -z "$GITHUB_REPO" ]]; then
    GITHUB_REPO="$DEFAULT_GITHUB_REPO"
fi

log "Se clone code tu: $GITHUB_REPO"

# Kiem tra Git
if ! command -v git &> /dev/null; then
    log "Cai dat Git..."
    sudo apt update
    sudo apt install -y git
fi

# Tao thu muc tam de clone
TEMP_DIR="/tmp/chat-deployment-$(date +%s)"
log "Tao thu muc tam: $TEMP_DIR"
mkdir -p $TEMP_DIR

# Clone repository
log "Clone repository tu GitHub..."
git clone $GITHUB_REPO $TEMP_DIR
if [[ $? -ne 0 ]]; then
    error "Khong the clone repository. Vui long kiem tra URL va quyen truy cap."
fi

# Chuyen den thu muc code
cd $TEMP_DIR

# Kiem tra files deployment
if [[ ! -f "deploy-all-in-one.sh" ]]; then
    error "Khong tim thay script deploy-all-in-one.sh trong repository."
fi

if [[ ! -f "package.json" ]]; then
    error "Khong tim thay package.json trong repository."
fi

# Cap quyen thuc thi
log "Cap quyen thuc thi cho scripts..."
chmod +x *.sh 2>/dev/null || true

# Thiet lap bien moi truong cho GitHub repo
export GITHUB_REPO="$GITHUB_REPO"

log "Chuan bi deploy tu GitHub repository..."
echo -e "\n${GREEN}Repository da duoc clone thanh cong!${NC}"
echo -e "Bay gio se chay script deploy chinh..."

# Chay script deploy chinh
echo -e "\n${BLUE}==================== BAT DAU DEPLOY ====================${NC}"
./deploy-all-in-one.sh

# Cleanup
log "Don dep thu muc tam..."
rm -rf $TEMP_DIR

echo -e "\n${GREEN}============================================================================"
echo "                    DEPLOY HOAN THANH!"
echo "============================================================================${NC}"