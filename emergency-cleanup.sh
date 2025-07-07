#!/bin/bash

# ==============================================================================
# EMERGENCY CLEANUP - XOA KHAU CAP NHANH
# Script xoa nhanh khi gap van de
# ==============================================================================

echo "=== EMERGENCY CLEANUP - XOA KHAU CAP ==="

# Stop tat ca processes
echo "1. Dung tat ca processes..."
sudo pkill -f "chat\|pm2\|nginx" 2>/dev/null || true
sudo pkill -f "node.*3000\|node.*5000" 2>/dev/null || true

# Xoa PM2
echo "2. Xoa PM2..."
pm2 kill 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Stop services
echo "3. Dung services..."
sudo systemctl stop nginx 2>/dev/null || true
sudo systemctl stop chatapp 2>/dev/null || true

# Xoa files nhanh
echo "4. Xoa files..."
sudo rm -rf /home/chatapp 2>/dev/null || true
sudo rm -rf /var/www/chat* 2>/dev/null || true
sudo rm -rf /opt/chat* 2>/dev/null || true

# Xoa database
echo "5. Xoa database..."
sudo -u postgres psql -c "DROP DATABASE IF EXISTS chatapp_db;" 2>/dev/null || true
sudo -u postgres psql -c "DROP USER IF EXISTS chatapp;" 2>/dev/null || true

# Xoa user
echo "6. Xoa user..."
sudo userdel -r chatapp 2>/dev/null || true

# Xoa scripts
echo "7. Xoa scripts..."
sudo rm -f /usr/local/bin/chatapp* 2>/dev/null || true
sudo rm -f /usr/local/bin/backup-chatapp* 2>/dev/null || true

# Xoa Nginx config
echo "8. Xoa Nginx config..."
sudo rm -f /etc/nginx/sites-*/chat* 2>/dev/null || true

# Khoi phuc Nginx
echo "9. Khoi phuc Nginx..."
if [[ -f /etc/nginx/sites-available/default ]]; then
    sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default 2>/dev/null || true
fi
sudo systemctl start nginx 2>/dev/null || true

echo "=== EMERGENCY CLEANUP HOAN THANH ==="
echo "He thong da duoc don sach khau cap!"
echo "Co the chay deploy moi ngay bay gio."