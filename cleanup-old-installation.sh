#!/bin/bash

# ==============================================================================
# CLEANUP OLD INSTALLATION - XOA CAI DAT CU
# Script xoa toan bo cai dat cu truoc khi cai dat moi
# ==============================================================================

set -e

# Mau sac
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

echo -e "${RED}"
echo "============================================================================"
echo "              XOA TOAN BO CAI DAT CU - CLEANUP SCRIPT"
echo "============================================================================"
echo -e "${NC}"

warn "Script nay se xoa toan bo cai dat cu cua chat system!"
warn "Bao gom: PM2 processes, Nginx config, Database, Files, Users"
echo ""
read -p "Ban co chac chan muon tiep tuc? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Huy bo."
    exit 1
fi

# Kiem tra quyen sudo
if ! sudo -n true 2>/dev/null; then
    error "Can quyen sudo de chay script nay"
    exit 1
fi

echo -e "\n${BLUE}==================== BAT DAU XOA CAI DAT CU ====================${NC}"

# 1. Stop va xoa PM2 processes
log "1. Dung va xoa PM2 processes..."
if command -v pm2 &> /dev/null; then
    pm2 stop all 2>/dev/null || true
    pm2 delete all 2>/dev/null || true
    pm2 kill 2>/dev/null || true
    pm2 flush 2>/dev/null || true
    info "Da xoa tat ca PM2 processes"
else
    info "PM2 khong ton tai, bo qua"
fi

# 2. Stop va xoa Nginx config
log "2. Xoa Nginx configuration..."
if systemctl is-active --quiet nginx 2>/dev/null; then
    sudo systemctl stop nginx
    info "Da dung Nginx"
fi

# Xoa cac file config Nginx lien quan
sudo rm -f /etc/nginx/sites-available/chat-system 2>/dev/null || true
sudo rm -f /etc/nginx/sites-enabled/chat-system 2>/dev/null || true
sudo rm -f /etc/nginx/sites-available/chatapp 2>/dev/null || true
sudo rm -f /etc/nginx/sites-enabled/chatapp 2>/dev/null || true

# Khoi phuc Nginx default neu can
if [[ -f /etc/nginx/sites-available/default ]] && [[ ! -f /etc/nginx/sites-enabled/default ]]; then
    sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default 2>/dev/null || true
fi

info "Da xoa Nginx config"

# 3. Xoa SSL certificates
log "3. Xoa SSL certificates..."
if command -v certbot &> /dev/null; then
    # Lay danh sach certificates
    CERTS=$(sudo certbot certificates 2>/dev/null | grep "Certificate Name:" | awk '{print $3}' || true)
    for cert in $CERTS; do
        if [[ "$cert" == *"chat"* ]] || [[ "$cert" == *"app"* ]]; then
            sudo certbot delete --cert-name "$cert" --non-interactive 2>/dev/null || true
            info "Da xoa SSL certificate: $cert"
        fi
    done
fi

# 4. Stop va xoa PostgreSQL databases
log "4. Xoa PostgreSQL databases..."
if systemctl is-active --quiet postgresql 2>/dev/null; then
    # Xoa database neu ton tai
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS chatapp_db;" 2>/dev/null || true
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS chat_system;" 2>/dev/null || true
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS chat_db;" 2>/dev/null || true
    
    # Xoa user neu ton tai
    sudo -u postgres psql -c "DROP USER IF EXISTS chatapp;" 2>/dev/null || true
    sudo -u postgres psql -c "DROP USER IF EXISTS chat_user;" 2>/dev/null || true
    sudo -u postgres psql -c "DROP USER IF EXISTS chatapp_user;" 2>/dev/null || true
    
    info "Da xoa PostgreSQL databases va users"
fi

# 5. Xoa system user
log "5. Xoa system user..."
if id "chatapp" &>/dev/null; then
    sudo pkill -u chatapp 2>/dev/null || true
    sleep 2
    sudo userdel -r chatapp 2>/dev/null || true
    info "Da xoa user: chatapp"
else
    info "User chatapp khong ton tai"
fi

# 6. Xoa application files
log "6. Xoa application files..."
sudo rm -rf /home/chatapp 2>/dev/null || true
sudo rm -rf /var/www/chat-system 2>/dev/null || true
sudo rm -rf /var/www/chatapp 2>/dev/null || true
sudo rm -rf /opt/chat-system 2>/dev/null || true
sudo rm -rf /opt/chatapp 2>/dev/null || true

info "Da xoa application directories"

# 7. Xoa system scripts
log "7. Xoa system scripts..."
sudo rm -f /usr/local/bin/chatapp-control.sh 2>/dev/null || true
sudo rm -f /usr/local/bin/backup-chatapp-db.sh 2>/dev/null || true
sudo rm -f /usr/local/bin/restore-chatapp-db.sh 2>/dev/null || true
sudo rm -f /usr/local/bin/update-chatapp.sh 2>/dev/null || true

info "Da xoa system scripts"

# 8. Xoa systemd services
log "8. Xoa systemd services..."
sudo systemctl stop chatapp 2>/dev/null || true
sudo systemctl disable chatapp 2>/dev/null || true
sudo rm -f /etc/systemd/system/chatapp.service 2>/dev/null || true
sudo systemctl daemon-reload

info "Da xoa systemd services"

# 9. Xoa cron jobs
log "9. Xoa cron jobs..."
sudo crontab -l 2>/dev/null | grep -v "chatapp\|chat-system" | sudo crontab - 2>/dev/null || true
info "Da xoa cron jobs"

# 10. Xoa log files
log "10. Xoa log files..."
sudo rm -rf /var/log/chatapp 2>/dev/null || true
sudo rm -rf /var/log/chat-system 2>/dev/null || true
sudo rm -rf /var/log/nginx/chatapp* 2>/dev/null || true

info "Da xoa log files"

# 11. Xoa backup files
log "11. Xoa backup files..."
sudo rm -rf /var/backups/chatapp* 2>/dev/null || true
sudo rm -rf /var/backups/chat-system* 2>/dev/null || true

info "Da xoa backup files"

# 12. Xoa firewall rules
log "12. Xoa firewall rules..."
if command -v ufw &> /dev/null; then
    sudo ufw --force delete allow 3000 2>/dev/null || true
    sudo ufw --force delete allow 'Nginx Full' 2>/dev/null || true
    sudo ufw --force delete allow 'Nginx HTTP' 2>/dev/null || true
    sudo ufw --force delete allow 'Nginx HTTPS' 2>/dev/null || true
    info "Da xoa firewall rules"
fi

# 13. Khoi phuc Nginx ve trang thai default
log "13. Khoi phuc Nginx..."
if command -v nginx &> /dev/null; then
    sudo nginx -t 2>/dev/null || true
    sudo systemctl start nginx 2>/dev/null || true
    info "Da khoi phuc Nginx"
fi

# 14. Xoa Node.js global packages lien quan
log "14. Xoa Node.js global packages..."
if command -v npm &> /dev/null; then
    npm uninstall -g pm2 2>/dev/null || true
    info "Da xoa global PM2"
fi

# 15. Don dep cache va temp files
log "15. Don dep cache..."
sudo rm -rf /tmp/chat* 2>/dev/null || true
sudo rm -rf /tmp/deploy* 2>/dev/null || true
sudo rm -rf ~/.pm2 2>/dev/null || true

info "Da don dep cache"

echo -e "\n${GREEN}============================================================================"
echo "                      XOA CAI DAT CU HOAN THANH!"
echo "============================================================================${NC}"

echo -e "\n${BLUE}KET QUA:${NC}"
echo "✓ PM2 processes da duoc xoa"
echo "✓ Nginx config da duoc don sach"
echo "✓ SSL certificates da duoc xoa"
echo "✓ PostgreSQL databases da duoc xoa"
echo "✓ System user da duoc xoa"
echo "✓ Application files da duoc xoa"
echo "✓ System scripts da duoc xoa"
echo "✓ Systemd services da duoc xoa"
echo "✓ Cron jobs da duoc xoa"
echo "✓ Log files da duoc xoa"
echo "✓ Backup files da duoc xoa"
echo "✓ Firewall rules da duoc xoa"
echo "✓ Cache da duoc don dep"

echo -e "\n${GREEN}HE THONG DA SAN SANG CHO CAI DAT MOI!${NC}"
echo -e "\nBan co the chay script deploy moi:"
echo -e "${YELLOW}curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github-fixed.sh | bash${NC}"

echo -e "\n${BLUE}============================================================================${NC}"