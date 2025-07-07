#!/bin/bash

# Simple cleanup script - Xoa cai dat cu don gian

echo "============================================================================"
echo "              XOA CAI DAT CU - SIMPLE CLEANUP"
echo "============================================================================"

echo "CANH BAO: Script nay se xoa toan bo cai dat cu!"
echo "Bao gom: PM2, Nginx config, Database, Files, Users"
echo ""
echo -n "Ban co chac chan muon tiep tuc? (y/N): "
read REPLY

if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]; then
    echo "Huy bo."
    exit 1
fi

echo "Bat dau cleanup..."

# 1. Stop PM2
echo "1. Dung PM2..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true
pm2 kill 2>/dev/null || true

# 2. Stop Nginx
echo "2. Dung Nginx..."
sudo systemctl stop nginx 2>/dev/null || true

# 3. Xoa Nginx config
echo "3. Xoa Nginx config..."
sudo rm -f /etc/nginx/sites-available/chat-system 2>/dev/null || true
sudo rm -f /etc/nginx/sites-enabled/chat-system 2>/dev/null || true
sudo rm -f /etc/nginx/sites-available/chatapp 2>/dev/null || true
sudo rm -f /etc/nginx/sites-enabled/chatapp 2>/dev/null || true

# 4. Xoa database
echo "4. Xoa database..."
sudo -u postgres psql -c "DROP DATABASE IF EXISTS chatapp_db;" 2>/dev/null || true
sudo -u postgres psql -c "DROP USER IF EXISTS chatapp;" 2>/dev/null || true

# 5. Xoa user
echo "5. Xoa user..."
sudo pkill -u chatapp 2>/dev/null || true
sleep 2
sudo userdel -r chatapp 2>/dev/null || true

# 6. Xoa files
echo "6. Xoa files..."
sudo rm -rf /home/chatapp 2>/dev/null || true
sudo rm -rf /var/www/chat-system 2>/dev/null || true
sudo rm -rf /var/www/chatapp 2>/dev/null || true
sudo rm -rf /opt/chat-system 2>/dev/null || true

# 7. Xoa scripts
echo "7. Xoa scripts..."
sudo rm -f /usr/local/bin/chatapp-control.sh 2>/dev/null || true
sudo rm -f /usr/local/bin/backup-chatapp-db.sh 2>/dev/null || true

# 8. Xoa systemd service
echo "8. Xoa systemd service..."
sudo systemctl stop chatapp 2>/dev/null || true
sudo systemctl disable chatapp 2>/dev/null || true
sudo rm -f /etc/systemd/system/chatapp.service 2>/dev/null || true
sudo systemctl daemon-reload

# 9. Xoa logs
echo "9. Xoa logs..."
sudo rm -rf /var/log/chatapp 2>/dev/null || true
sudo rm -rf /var/log/chat-system 2>/dev/null || true

# 10. Khoi phuc Nginx
echo "10. Khoi phuc Nginx..."
if [ -f /etc/nginx/sites-available/default ]; then
    sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default 2>/dev/null || true
fi
sudo systemctl start nginx 2>/dev/null || true

echo ""
echo "============================================================================"
echo "                    CLEANUP HOAN THANH!"
echo "============================================================================"
echo ""
echo "He thong da duoc don sach!"
echo "Co the chay deploy moi:"
echo "curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github-fixed.sh | bash"