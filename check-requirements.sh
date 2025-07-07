#!/bin/bash

# ==============================================================================
# SCRIPT KIEM TRA YEU CAU HE THONG
# Kiem tra VPS co du yeu cau de chay Real-time Chat System khong
# ==============================================================================

# Mau sac cho terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Bien dem
PASSED=0
FAILED=0
WARNINGS=0

# Ham logging
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
echo "    KIEM TRA YEU CAU HE THONG - REAL-TIME CHAT SYSTEM"
echo "============================================================================"
echo -e "${NC}"

# Kiem tra he dieu hanh
echo -e "\n${BLUE}1. KIEM TRA HE DIEU HANH${NC}"
if grep -q "Ubuntu 20.04" /etc/os-release; then
    pass "Ubuntu 20.04 LTS"
elif grep -q "Ubuntu" /etc/os-release; then
    warn "Ubuntu $(grep VERSION_ID /etc/os-release | cut -d'"' -f2) - Khuyen nghi Ubuntu 20.04"
else
    fail "Khong phai Ubuntu - Script duoc thiet ke cho Ubuntu 20.04"
fi

# Kiem tra quyen sudo
echo -e "\n${BLUE}2. KIEM TRA QUYEN SUDO${NC}"
if sudo -n true 2>/dev/null; then
    pass "Co quyen sudo"
else
    fail "Khong co quyen sudo - Can thiet de cai dat"
fi

# Kiem tra RAM
echo -e "\n${BLUE}3. KIEM TRA BO NHO RAM${NC}"
RAM_MB=$(free -m | awk 'NR==2{printf "%.0f", $2}')
if [ "$RAM_MB" -ge 4096 ]; then
    pass "RAM: ${RAM_MB}MB (Tuyet voi)"
elif [ "$RAM_MB" -ge 2048 ]; then
    pass "RAM: ${RAM_MB}MB (Du yeu cau)"
elif [ "$RAM_MB" -ge 1024 ]; then
    warn "RAM: ${RAM_MB}MB (Thap, co the cham)"
else
    fail "RAM: ${RAM_MB}MB (Khong du, can toi thieu 1GB)"
fi

# Kiem tra CPU
echo -e "\n${BLUE}4. KIEM TRA CPU${NC}"
CPU_CORES=$(nproc)
if [ "$CPU_CORES" -ge 4 ]; then
    pass "CPU: ${CPU_CORES} cores (Tuyet voi)"
elif [ "$CPU_CORES" -ge 2 ]; then
    pass "CPU: ${CPU_CORES} cores (Du yeu cau)"
else
    warn "CPU: ${CPU_CORES} core (Thap, khuyen nghi 2+ cores)"
fi

# Kiem tra dung luong o cung
echo -e "\n${BLUE}5. KIEM TRA DUNG LUONG O CUNG${NC}"
DISK_AVAILABLE=$(df / | awk 'NR==2 {print $4}')
DISK_AVAILABLE_GB=$((DISK_AVAILABLE / 1024 / 1024))
if [ "$DISK_AVAILABLE_GB" -ge 20 ]; then
    pass "Dung luong trong: ${DISK_AVAILABLE_GB}GB (Du yeu cau)"
elif [ "$DISK_AVAILABLE_GB" -ge 10 ]; then
    warn "Dung luong trong: ${DISK_AVAILABLE_GB}GB (It, can theo doi)"
else
    fail "Dung luong trong: ${DISK_AVAILABLE_GB}GB (Khong du, can toi thieu 10GB)"
fi

# Kiem tra ket noi internet
echo -e "\n${BLUE}6. KIEM TRA KET NOI INTERNET${NC}"
if ping -c 1 google.com >/dev/null 2>&1; then
    pass "Ket noi internet hoat dong"
else
    fail "Khong co ket noi internet"
fi

# Kiem tra port can thiet
echo -e "\n${BLUE}7. KIEM TRA PORTS${NC}"
PORTS_TO_CHECK=(80 443 3000 5432)
for port in "${PORTS_TO_CHECK[@]}"; do
    if ss -tuln | grep -q ":$port "; then
        warn "Port $port dang duoc su dung"
    else
        pass "Port $port co san"
    fi
done

# Kiem tra DNS resolution
echo -e "\n${BLUE}8. KIEM TRA DNS${NC}"
if nslookup google.com >/dev/null 2>&1; then
    pass "DNS resolution hoat dong"
else
    fail "Loi DNS resolution"
fi

# Kiem tra timezone
echo -e "\n${BLUE}9. KIEM TRA TIMEZONE${NC}"
TIMEZONE=$(timedatectl | grep "Time zone" | awk '{print $3}')
info "Timezone hien tai: $TIMEZONE"
if [[ "$TIMEZONE" == "Asia/Ho_Chi_Minh" || "$TIMEZONE" == "UTC" ]]; then
    pass "Timezone phu hop"
else
    warn "Timezone khong phai Asia/Ho_Chi_Minh hoac UTC"
fi

# Kiem tra software da cai
echo -e "\n${BLUE}10. KIEM TRA PHAN MEM DA CAI${NC}"
SOFTWARE_CHECK=(curl wget git)
for software in "${SOFTWARE_CHECK[@]}"; do
    if command -v $software >/dev/null 2>&1; then
        pass "$software da duoc cai dat"
    else
        warn "$software chua duoc cai dat (se duoc cai tu dong)"
    fi
done

# Kiem tra cac dich vu xung dot
echo -e "\n${BLUE}11. KIEM TRA XUNG DOT DICH VU${NC}"
CONFLICTING_SERVICES=(apache2 mysql mariadb nginx nodejs postgresql)
for service in "${CONFLICTING_SERVICES[@]}"; do
    if systemctl is-active --quiet $service 2>/dev/null; then
        warn "$service dang chay - co the xung dot"
    else
        pass "$service khong chay"
    fi
done

# Kiem tra firewall
echo -e "\n${BLUE}12. KIEM TRA FIREWALL${NC}"
if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(ufw status | head -1)
    if [[ "$UFW_STATUS" == *"inactive"* ]]; then
        pass "UFW firewall tat (se duoc cau hinh)"
    else
        warn "UFW firewall dang hoat dong (can kiem tra rules)"
    fi
else
    warn "UFW chua duoc cai dat (se duoc cai tu dong)"
fi

# Kiem tra package.json
echo -e "\n${BLUE}13. KIEM TRA SOURCE CODE${NC}"
if [[ -f "package.json" ]]; then
    pass "package.json co san"
    if [[ -f "deploy-all-in-one.sh" ]]; then
        pass "Script trien khai co san"
    else
        fail "Khong tim thay deploy-all-in-one.sh"
    fi
else
    fail "Khong tim thay package.json - Vui long chay tu thu muc source code"
fi

# Tong ket
echo -e "\n${BLUE}============================================================================${NC}"
echo -e "${BLUE}                              TOM TAT KET QUA${NC}"
echo -e "${BLUE}============================================================================${NC}"

echo -e "${GREEN}✓ Dat yeu cau: $PASSED${NC}"
echo -e "${YELLOW}⚠ Canh bao: $WARNINGS${NC}"
echo -e "${RED}✗ Loi: $FAILED${NC}"

if [ "$FAILED" -eq 0 ]; then
    if [ "$WARNINGS" -eq 0 ]; then
        echo -e "\n${GREEN}🎉 HE THONG HOAN HAO! San sang trien khai.${NC}"
        echo -e "${GREEN}Chay lenh: ./deploy-all-in-one.sh${NC}"
    else
        echo -e "\n${YELLOW}⚠️  HE THONG CO THE TRIEN KHAI nhung co mot so canh bao.${NC}"
        echo -e "${YELLOW}Khuyen nghi xem xet cac canh bao truoc khi trien khai.${NC}"
        echo -e "\n${BLUE}Tiep tuc trien khai: ./deploy-all-in-one.sh${NC}"
    fi
else
    echo -e "\n${RED}❌ HE THONG CHUA SAN SANG! Can khac phuc cac loi truoc.${NC}"
    echo -e "${RED}Vui long khac phuc cac loi do va chay lai script kiem tra.${NC}"
fi

echo -e "\n${BLUE}Ghi chu:${NC}"
echo -e "• Script nay chi kiem tra yeu cau co ban"
echo -e "• Mot so van de se duoc tu dong khac phuc trong qua trinh trien khai"
echo -e "• Dam bao domain name da tro ve IP VPS truoc khi trien khai"

echo -e "\n${BLUE}============================================================================${NC}"