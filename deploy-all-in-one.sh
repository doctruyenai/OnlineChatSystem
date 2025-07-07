#!/bin/bash

# ==============================================================================
# REAL-TIME CHAT SYSTEM - SCRIPT TRIỂN KHAI ALL-IN-ONE
# Dành cho Ubuntu 20.04 LTS
# ==============================================================================

set -e  # Dừng script khi có lỗi

# Màu sắc cho terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load cấu hình từ file (nếu có)
if [[ -f "deployment.config.sh" ]]; then
    source deployment.config.sh
    log "Đã load cấu hình từ deployment.config.sh"
fi

# Cấu hình mặc định (sẽ được ghi đè bởi config file hoặc input)
APP_NAME="${APP_NAME:-chatapp}"
APP_USER="${APP_USER:-chatapp}"
APP_DIR="/home/$APP_USER/chat-system"
DB_NAME="${DB_NAME:-chatapp_db}"
DB_USER="${DB_USER:-chatapp_user}"
APP_PORT="${APP_PORT:-3000}"
DOMAIN=""  # Sẽ được nhập trong quá trình cài đặt
SSL_EMAIL=""  # Email cho SSL certificate

# Logging
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

# Kiểm tra quyền root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "Script này không nên chạy với quyền root. Vui lòng chạy với user thường."
    fi
}

# Kiểm tra hệ điều hành
check_os() {
    if ! grep -q "Ubuntu 20.04" /etc/os-release; then
        warn "Script này được thiết kế cho Ubuntu 20.04. Có thể gặp vấn đề trên phiên bản khác."
        read -p "Bạn có muốn tiếp tục? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Thu thập thông tin từ người dùng
gather_info() {
    echo -e "${BLUE}==================== CẤU HÌNH TRIỂN KHAI ====================${NC}"
    
    # Domain name
    read -p "Nhập domain name (ví dụ: example.com): " DOMAIN
    while [[ -z "$DOMAIN" ]]; do
        read -p "Domain không được để trống. Vui lòng nhập lại: " DOMAIN
    done
    
    # Email cho SSL
    read -p "Nhập email cho SSL certificate: " SSL_EMAIL
    while [[ -z "$SSL_EMAIL" ]]; do
        read -p "Email không được để trống. Vui lòng nhập lại: " SSL_EMAIL
    done
    
    # Database password
    echo -n "Nhập mật khẩu cho database PostgreSQL: "
    read -s DB_PASSWORD
    echo
    while [[ -z "$DB_PASSWORD" ]]; do
        echo -n "Mật khẩu không được để trống. Vui lòng nhập lại: "
        read -s DB_PASSWORD
        echo
    done
    
    # Session secret
    echo -n "Nhập session secret (ít nhất 32 ký tự): "
    read -s SESSION_SECRET
    echo
    while [[ ${#SESSION_SECRET} -lt 32 ]]; do
        echo -n "Session secret phải có ít nhất 32 ký tự. Vui lòng nhập lại: "
        read -s SESSION_SECRET
        echo
    done
    
    echo -e "${GREEN}✓ Đã thu thập thông tin cấu hình${NC}"
}

# Cập nhật hệ thống
update_system() {
    log "Cập nhật hệ thống..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl wget git ufw software-properties-common apt-transport-https ca-certificates gnupg lsb-release
}

# Cài đặt Node.js 20.x
install_nodejs() {
    log "Cài đặt Node.js 20.x..."
    
    # Xóa Node.js cũ nếu có
    sudo apt remove -y nodejs npm
    
    # Thêm NodeSource repository
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    
    # Cài đặt Node.js
    sudo apt-get install -y nodejs
    
    # Kiểm tra phiên bản
    node_version=$(node --version)
    npm_version=$(npm --version)
    log "Node.js đã được cài đặt: $node_version"
    log "npm đã được cài đặt: $npm_version"
    
    # Cài đặt PM2
    sudo npm install -g pm2
    log "PM2 đã được cài đặt"
}

# Cài đặt PostgreSQL
install_postgresql() {
    log "Cài đặt PostgreSQL..."
    
    sudo apt install -y postgresql postgresql-contrib
    
    # Khởi động và enable PostgreSQL
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    
    log "PostgreSQL đã được cài đặt và khởi động"
}

# Cấu hình PostgreSQL
configure_postgresql() {
    log "Cấu hình PostgreSQL..."
    
    # Tạo database và user
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
    sudo -u postgres psql -c "CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASSWORD';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    sudo -u postgres psql -c "ALTER USER $DB_USER CREATEDB;"
    
    # Cấu hình authentication
    PG_VERSION=$(sudo -u postgres psql -t -c "SELECT version();" | grep -oP '(?<=PostgreSQL )\d+')
    PG_CONFIG_DIR="/etc/postgresql/$PG_VERSION/main"
    
    # Backup cấu hình cũ
    sudo cp "$PG_CONFIG_DIR/pg_hba.conf" "$PG_CONFIG_DIR/pg_hba.conf.backup"
    
    # Thêm cấu hình authentication cho user mới
    echo "local   $DB_NAME        $DB_USER                                md5" | sudo tee -a "$PG_CONFIG_DIR/pg_hba.conf"
    
    # Restart PostgreSQL
    sudo systemctl restart postgresql
    
    log "PostgreSQL đã được cấu hình"
}

# Cài đặt Nginx
install_nginx() {
    log "Cài đặt Nginx..."
    
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    log "Nginx đã được cài đặt và khởi động"
}

# Tạo user cho ứng dụng
create_app_user() {
    log "Tạo user cho ứng dụng..."
    
    if ! id "$APP_USER" &>/dev/null; then
        sudo adduser --disabled-password --gecos "" $APP_USER
        sudo usermod -aG sudo $APP_USER
        log "User $APP_USER đã được tạo"
    else
        log "User $APP_USER đã tồn tại"
    fi
}

# Clone và build ứng dụng
deploy_application() {
    log "Triển khai ứng dụng..."
    
    # Tạo thư mục ứng dụng
    sudo mkdir -p $APP_DIR
    sudo chown $APP_USER:$APP_USER $APP_DIR
    
    # Copy source code (giả sử script chạy từ thư mục source)
    if [[ -f "package.json" ]]; then
        log "Copy source code từ thư mục hiện tại..."
        sudo cp -r . $APP_DIR/
        sudo chown -R $APP_USER:$APP_USER $APP_DIR
    else
        error "Không tìm thấy package.json. Vui lòng chạy script từ thư mục source code."
    fi
    
    # Chuyển sang user app để build
    sudo -u $APP_USER bash -c "
        cd $APP_DIR
        
        # Cài đặt dependencies
        npm install
        
        # Build ứng dụng
        npm run build
        
        # Tạo thư mục logs
        mkdir -p logs
    "
    
    log "Ứng dụng đã được build thành công"
}

# Tạo file environment
create_env_file() {
    log "Tạo file cấu hình environment..."
    
    # Tạo DATABASE_URL
    DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
    
    # Tạo file .env
    sudo -u $APP_USER bash -c "cat > $APP_DIR/.env << EOF
NODE_ENV=production
PORT=3000
DATABASE_URL=$DATABASE_URL
SESSION_SECRET=$SESSION_SECRET
EOF"
    
    log "File .env đã được tạo"
}

# Push database schema
setup_database_schema() {
    log "Thiết lập schema database..."
    
    sudo -u $APP_USER bash -c "
        cd $APP_DIR
        npm run db:push
    "
    
    log "Database schema đã được thiết lập"
}

# Cấu hình PM2
configure_pm2() {
    log "Cấu hình PM2..."
    
    # Start ứng dụng với PM2
    sudo -u $APP_USER bash -c "
        cd $APP_DIR
        pm2 start ecosystem.config.js --env production
        pm2 save
        pm2 startup
    "
    
    # Cấu hình PM2 startup cho system
    sudo env PATH=\$PATH:/usr/bin /home/$APP_USER/.npm-global/bin/pm2 startup systemd -u $APP_USER --hp /home/$APP_USER
    
    log "PM2 đã được cấu hình"
}

# Cấu hình Nginx
configure_nginx() {
    log "Cấu hình Nginx..."
    
    # Tạo file cấu hình site
    sudo tee /etc/nginx/sites-available/$APP_NAME << EOF
upstream chatapp {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;
    
    # SSL configuration (sẽ được cập nhật bởi Certbot)
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # WebSocket proxy for real-time chat
    location /ws {
        proxy_pass http://chatapp;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 86400;
    }
    
    # API routes
    location /api {
        proxy_pass http://chatapp;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Widget files with CORS headers
    location ~ ^/(widget\.js|widget\.css)$ {
        proxy_pass http://chatapp;
        proxy_set_header Host \$host;
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods "GET, OPTIONS";
        add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept";
        
        # Handle preflight requests
        if (\$request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods "GET, OPTIONS";
            add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept";
            add_header Access-Control-Max-Age 1728000;
            add_header Content-Type "text/plain charset=UTF-8";
            add_header Content-Length 0;
            return 204;
        }
    }
    
    # Static files and main application
    location / {
        proxy_pass http://chatapp;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Security
    location ~ /\. {
        deny all;
    }
}
EOF
    
    # Enable site
    sudo ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test cấu hình
    sudo nginx -t
    
    log "Nginx đã được cấu hình"
}

# Cài đặt SSL với Let's Encrypt
install_ssl() {
    log "Cài đặt SSL certificate..."
    
    # Cài đặt Certbot
    sudo apt install -y certbot python3-certbot-nginx
    
    # Tạm thời tắt SSL trong cấu hình Nginx để có thể lấy certificate
    sudo sed -i '/ssl_certificate/d' /etc/nginx/sites-available/$APP_NAME
    sudo sed -i 's/listen 443 ssl http2;/listen 443;/' /etc/nginx/sites-available/$APP_NAME
    sudo systemctl reload nginx
    
    # Lấy certificate
    sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --email $SSL_EMAIL --agree-tos --non-interactive --redirect
    
    log "SSL certificate đã được cài đặt"
}

# Cấu hình firewall
configure_firewall() {
    log "Cấu hình firewall..."
    
    sudo ufw --force enable
    sudo ufw allow ssh
    sudo ufw allow 'Nginx Full'
    sudo ufw allow 80
    sudo ufw allow 443
    
    log "Firewall đã được cấu hình"
}

# Tạo script backup database
create_backup_script() {
    log "Tạo script backup database..."
    
    sudo tee /usr/local/bin/backup-chatapp-db.sh << EOF
#!/bin/bash
BACKUP_DIR="/home/$APP_USER/backups"
DATE=\$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="\$BACKUP_DIR/chatapp_db_\$DATE.sql"

mkdir -p \$BACKUP_DIR

sudo -u postgres pg_dump $DB_NAME > \$BACKUP_FILE
gzip \$BACKUP_FILE

# Xóa backup cũ hơn 7 ngày
find \$BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "Database backup completed: \$BACKUP_FILE.gz"
EOF
    
    sudo chmod +x /usr/local/bin/backup-chatapp-db.sh
    
    # Tạo cron job backup hàng ngày
    (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-chatapp-db.sh") | crontab -
    
    log "Script backup đã được tạo"
}

# Tạo script restart ứng dụng
create_restart_script() {
    log "Tạo script quản lý ứng dụng..."
    
    sudo tee /usr/local/bin/chatapp-control.sh << EOF
#!/bin/bash

case "\$1" in
    start)
        sudo -u $APP_USER bash -c "cd $APP_DIR && pm2 start ecosystem.config.js"
        ;;
    stop)
        sudo -u $APP_USER bash -c "cd $APP_DIR && pm2 stop all"
        ;;
    restart)
        sudo -u $APP_USER bash -c "cd $APP_DIR && pm2 restart all"
        ;;
    status)
        sudo -u $APP_USER bash -c "cd $APP_DIR && pm2 status"
        ;;
    logs)
        sudo -u $APP_USER bash -c "cd $APP_DIR && pm2 logs"
        ;;
    update)
        echo "Stopping application..."
        sudo -u $APP_USER bash -c "cd $APP_DIR && pm2 stop all"
        
        echo "Pulling latest changes..."
        sudo -u $APP_USER bash -c "cd $APP_DIR && git pull"
        
        echo "Installing dependencies..."
        sudo -u $APP_USER bash -c "cd $APP_DIR && npm install"
        
        echo "Building application..."
        sudo -u $APP_USER bash -c "cd $APP_DIR && npm run build"
        
        echo "Updating database schema..."
        sudo -u $APP_USER bash -c "cd $APP_DIR && npm run db:push"
        
        echo "Starting application..."
        sudo -u $APP_USER bash -c "cd $APP_DIR && pm2 start ecosystem.config.js"
        ;;
    *)
        echo "Usage: \$0 {start|stop|restart|status|logs|update}"
        exit 1
        ;;
esac
EOF
    
    sudo chmod +x /usr/local/bin/chatapp-control.sh
    
    log "Script quản lý ứng dụng đã được tạo"
}

# Tạo user admin mặc định
create_admin_user() {
    log "Tạo user admin mặc định..."
    
    # Tạo script tạo admin user
    sudo -u $APP_USER tee $APP_DIR/create-admin.js << 'EOF'
const { drizzle } = require('drizzle-orm/node-postgres');
const { Pool } = require('pg');
const { users } = require('./shared/schema.js');
const { scrypt, randomBytes } = require('crypto');
const { promisify } = require('util');

const scryptAsync = promisify(scrypt);

async function hashPassword(password) {
  const salt = randomBytes(16).toString('hex');
  const derivedKey = await scryptAsync(password, salt, 32);
  return salt + ':' + derivedKey.toString('hex');
}

async function createAdmin() {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  const db = drizzle(pool, { schema: { users } });
  
  try {
    const hashedPassword = await hashPassword('admin123');
    
    await db.insert(users).values({
      username: 'admin',
      password: hashedPassword,
      email: 'admin@example.com',
      firstName: 'Admin',
      lastName: 'User',
      role: 'admin'
    });
    
    console.log('Admin user created successfully!');
    console.log('Username: admin');
    console.log('Password: admin123');
    console.log('Please change the password after first login.');
  } catch (error) {
    if (error.code === '23505') {
      console.log('Admin user already exists.');
    } else {
      console.error('Error creating admin user:', error);
    }
  } finally {
    await pool.end();
  }
}

createAdmin();
EOF
    
    # Chạy script tạo admin
    sudo -u $APP_USER bash -c "cd $APP_DIR && node create-admin.js"
    
    # Xóa script sau khi sử dụng
    sudo rm $APP_DIR/create-admin.js
    
    log "User admin đã được tạo"
}

# Kiểm tra trạng thái dịch vụ
check_services() {
    log "Kiểm tra trạng thái các dịch vụ..."
    
    # Kiểm tra PostgreSQL
    if sudo systemctl is-active --quiet postgresql; then
        echo -e "${GREEN}✓ PostgreSQL đang hoạt động${NC}"
    else
        echo -e "${RED}✗ PostgreSQL không hoạt động${NC}"
    fi
    
    # Kiểm tra Nginx
    if sudo systemctl is-active --quiet nginx; then
        echo -e "${GREEN}✓ Nginx đang hoạt động${NC}"
    else
        echo -e "${RED}✗ Nginx không hoạt động${NC}"
    fi
    
    # Kiểm tra ứng dụng
    if sudo -u $APP_USER bash -c "cd $APP_DIR && pm2 list | grep -q online"; then
        echo -e "${GREEN}✓ Ứng dụng Chat đang hoạt động${NC}"
    else
        echo -e "${RED}✗ Ứng dụng Chat không hoạt động${NC}"
    fi
    
    # Test kết nối HTTP
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|301\|302"; then
        echo -e "${GREEN}✓ Ứng dụng phản hồi HTTP${NC}"
    else
        echo -e "${RED}✗ Ứng dụng không phản hồi HTTP${NC}"
    fi
}

# Hiển thị thông tin hoàn thành
show_completion_info() {
    echo -e "\n${GREEN}==================== TRIỂN KHAI HOÀN THÀNH ====================${NC}"
    echo -e "${GREEN}✓ Hệ thống Real-time Chat đã được triển khai thành công!${NC}\n"
    
    echo -e "${BLUE}Thông tin truy cập:${NC}"
    echo -e "  • Website: https://$DOMAIN"
    echo -e "  • Admin Panel: https://$DOMAIN (đăng nhập với admin/admin123)"
    echo -e "  • Widget JS: https://$DOMAIN/widget.js"
    echo -e "  • Widget CSS: https://$DOMAIN/widget.css"
    
    echo -e "\n${BLUE}Thông tin đăng nhập admin mặc định:${NC}"
    echo -e "  • Username: admin"
    echo -e "  • Password: admin123"
    echo -e "  • ${YELLOW}⚠️  Vui lòng đổi mật khẩu sau khi đăng nhập lần đầu${NC}"
    
    echo -e "\n${BLUE}Lệnh quản lý hệ thống:${NC}"
    echo -e "  • Khởi động: sudo /usr/local/bin/chatapp-control.sh start"
    echo -e "  • Dừng: sudo /usr/local/bin/chatapp-control.sh stop"
    echo -e "  • Restart: sudo /usr/local/bin/chatapp-control.sh restart"
    echo -e "  • Xem trạng thái: sudo /usr/local/bin/chatapp-control.sh status"
    echo -e "  • Xem logs: sudo /usr/local/bin/chatapp-control.sh logs"
    echo -e "  • Cập nhật: sudo /usr/local/bin/chatapp-control.sh update"
    
    echo -e "\n${BLUE}Tích hợp Widget vào website:${NC}"
    echo -e "  Thêm code sau vào trang web của bạn:"
    echo -e "${YELLOW}  <link rel=\"stylesheet\" href=\"https://$DOMAIN/widget.css\">"
    echo -e "  <script src=\"https://$DOMAIN/widget.js\"></script>"
    echo -e "  <script>"
    echo -e "    window.LiveChatConfig = {"
    echo -e "      domain: '$DOMAIN',"
    echo -e "      position: 'bottom-right',"
    echo -e "      primaryColor: '#007bff',"
    echo -e "      title: 'Hỗ trợ khách hàng'"
    echo -e "    };"
    echo -e "  </script>${NC}"
    
    echo -e "\n${BLUE}Thư mục và file quan trọng:${NC}"
    echo -e "  • Ứng dụng: $APP_DIR"
    echo -e "  • Logs: $APP_DIR/logs/"
    echo -e "  • Backup: /home/$APP_USER/backups/"
    echo -e "  • Nginx config: /etc/nginx/sites-available/$APP_NAME"
    echo -e "  • SSL certificates: /etc/letsencrypt/live/$DOMAIN/"
    
    echo -e "\n${GREEN}==================== TRIỂN KHAI THÀNH CÔNG ====================${NC}"
}

# Hàm main
main() {
    echo -e "${BLUE}"
    echo "============================================================================"
    echo "    REAL-TIME CHAT SYSTEM - SCRIPT TRIỂN KHAI TỰ ĐỘNG"
    echo "    Phiên bản: 1.0"
    echo "    Hệ điều hành: Ubuntu 20.04 LTS"
    echo "============================================================================"
    echo -e "${NC}"
    
    # Kiểm tra điều kiện
    check_root
    check_os
    
    # Thu thập thông tin
    gather_info
    
    echo -e "\n${BLUE}Bắt đầu quá trình triển khai...${NC}"
    
    # Thực hiện các bước triển khai
    update_system
    install_nodejs
    install_postgresql
    configure_postgresql
    install_nginx
    create_app_user
    deploy_application
    create_env_file
    setup_database_schema
    configure_pm2
    configure_nginx
    configure_firewall
    install_ssl
    create_backup_script
    create_restart_script
    create_admin_user
    
    # Restart các dịch vụ
    sudo systemctl restart nginx
    sudo -u $APP_USER bash -c "cd $APP_DIR && pm2 restart all"
    
    # Kiểm tra trạng thái
    sleep 5
    check_services
    
    # Hiển thị thông tin hoàn thành
    show_completion_info
}

# Chạy script
main "$@"