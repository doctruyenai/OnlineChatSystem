#!/bin/bash

# ==============================================================================
# REAL-TIME CHAT SYSTEM - SCRIPT TRIEN KHAI ALL-IN-ONE
# Danh cho Ubuntu 20.04 LTS
# ==============================================================================

set -e  # Dung script khi co loi

# Mau sac cho terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load cau hinh tu file (neu co)
if [[ -f "deployment.config.sh" ]]; then
    source deployment.config.sh
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] Da load cau hinh tu deployment.config.sh${NC}"
fi

# Cau hinh mac dinh (se duoc ghi de boi config file hoac input)
APP_NAME="${APP_NAME:-chatapp}"
APP_USER="${APP_USER:-chatapp}"
APP_DIR="/home/$APP_USER/chat-system"
DB_NAME="${DB_NAME:-chatapp_db}"
DB_USER="${DB_USER:-chatapp_user}"
APP_PORT="${APP_PORT:-3000}"
DOMAIN=""  # Se duoc nhap trong qua trinh cai dat
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

# Kiem tra quyen root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "Script nay khong nen chay voi quyen root. Vui long chay voi user thuong."
    fi
}

# Kiem tra he dieu hanh
check_os() {
    if ! grep -q "Ubuntu 20.04" /etc/os-release; then
        warn "Script nay duoc thiet ke cho Ubuntu 20.04. Co the gap van de tren phien ban khac."
        read -p "Ban co muon tiep tuc? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Thu thap thong tin tu nguoi dung
gather_info() {
    echo -e "${BLUE}==================== CAU HINH TRIEN KHAI ====================${NC}"
    
    # GitHub Repository (tuy chon)
    if [[ -z "${GITHUB_REPO:-}" ]]; then
        echo -e "\n${YELLOW}GitHub Repository (tuy chon):${NC}"
        echo "Neu ban muon deploy tu GitHub repository, nhap URL:"
        echo "Vi du: https://github.com/doctruyenai/OnlineChatSystem"
        read -p "GitHub Repository URL (de trong neu dung code local): " GITHUB_REPO
        
        if [[ -n "$GITHUB_REPO" ]]; then
            log "Se clone code tu: $GITHUB_REPO"
        else
            log "Se su dung code tu thu muc hien tai"
        fi
    fi
    
    # Domain name
    read -p "Nhap domain name (vi du: example.com): " DOMAIN
    while [[ -z "$DOMAIN" ]]; do
        read -p "Domain khong duoc de trong. Vui long nhap lai: " DOMAIN
    done
    
    # Email cho SSL
    read -p "Nhap email cho SSL certificate: " SSL_EMAIL
    while [[ -z "$SSL_EMAIL" ]]; do
        read -p "Email khong duoc de trong. Vui long nhap lai: " SSL_EMAIL
    done
    
    # Database password
    echo -n "Nhap mat khau cho database PostgreSQL: "
    read -s DB_PASSWORD
    echo
    while [[ -z "$DB_PASSWORD" ]]; do
        echo -n "Mat khau khong duoc de trong. Vui long nhap lai: "
        read -s DB_PASSWORD
        echo
    done
    
    # Session secret
    echo -n "Nhap session secret (it nhat 32 ky tu): "
    read -s SESSION_SECRET
    echo
    while [[ ${#SESSION_SECRET} -lt 32 ]]; do
        echo -n "Session secret phai co it nhat 32 ky tu. Vui long nhap lai: "
        read -s SESSION_SECRET
        echo
    done
    
    echo -e "${GREEN}✓ Da thu thap thong tin cau hinh${NC}"
}

# Cap nhat he thong
update_system() {
    log "Cap nhat he thong..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl wget git ufw software-properties-common apt-transport-https ca-certificates gnupg lsb-release
}

# Cai dat Node.js 20.x
install_nodejs() {
    log "Cai dat Node.js 20.x..."
    
    # Xoa Node.js cu neu co
    sudo apt remove -y nodejs npm
    
    # Them NodeSource repository
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    
    # Cai dat Node.js
    sudo apt-get install -y nodejs
    
    # Kiem tra phien ban
    node_version=$(node --version)
    npm_version=$(npm --version)
    log "Node.js da duoc cai dat: $node_version"
    log "npm da duoc cai dat: $npm_version"
    
    # Cai dat PM2
    sudo npm install -g pm2
    log "PM2 da duoc cai dat"
}

# Cai dat PostgreSQL
install_postgresql() {
    log "Cai dat PostgreSQL..."
    
    sudo apt install -y postgresql postgresql-contrib
    
    # Khoi dong va enable PostgreSQL
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    
    log "PostgreSQL da duoc cai dat va khoi dong"
}

# Cau hinh PostgreSQL
configure_postgresql() {
    log "Cau hinh PostgreSQL..."
    
    # Tao database va user
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
    sudo -u postgres psql -c "CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASSWORD';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    sudo -u postgres psql -c "ALTER USER $DB_USER CREATEDB;"
    
    # Cau hinh authentication
    PG_VERSION=$(sudo -u postgres psql -t -c "SELECT version();" | grep -oP '(?<=PostgreSQL )\d+')
    PG_CONFIG_DIR="/etc/postgresql/$PG_VERSION/main"
    
    # Backup cau hinh cu
    sudo cp "$PG_CONFIG_DIR/pg_hba.conf" "$PG_CONFIG_DIR/pg_hba.conf.backup"
    
    # Them cau hinh authentication cho user moi
    echo "local   $DB_NAME        $DB_USER                                md5" | sudo tee -a "$PG_CONFIG_DIR/pg_hba.conf"
    
    # Restart PostgreSQL
    sudo systemctl restart postgresql
    
    log "PostgreSQL da duoc cau hinh"
}

# Cai dat Nginx
install_nginx() {
    log "Cai dat Nginx..."
    
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    log "Nginx da duoc cai dat va khoi dong"
}

# Tao user cho ung dung
create_app_user() {
    log "Tao user cho ung dung..."
    
    if ! id "$APP_USER" &>/dev/null; then
        sudo adduser --disabled-password --gecos "" $APP_USER
        sudo usermod -aG sudo $APP_USER
        log "User $APP_USER da duoc tao"
    else
        log "User $APP_USER da ton tai"
    fi
}

# Clone va build ung dung
deploy_application() {
    log "Trien khai ung dung..."
    
    # Tao thu muc ung dung
    sudo mkdir -p $APP_DIR
    sudo chown $APP_USER:$APP_USER $APP_DIR
    
    # Clone source code tu GitHub hoac copy tu local
    if [[ -n "${GITHUB_REPO:-}" ]]; then
        log "Clone source code tu GitHub repository: $GITHUB_REPO"
        sudo -u $APP_USER git clone $GITHUB_REPO $APP_DIR
        if [[ $? -ne 0 ]]; then
            error "Khong the clone repository tu GitHub. Vui long kiem tra URL va quyen truy cap."
        fi
    elif [[ -f "package.json" ]]; then
        log "Copy source code tu thu muc hien tai..."
        sudo cp -r . $APP_DIR/
        sudo chown -R $APP_USER:$APP_USER $APP_DIR
    else
        error "Khong tim thay package.json va khong co GITHUB_REPO. Vui long chay script tu thu muc source code hoac cung cap GitHub repository."
    fi
    
    # Cau hinh Git cho user app
    sudo -u $APP_USER bash -c "
        git config --global user.name 'Chat System Deployment'
        git config --global user.email 'deploy@$DOMAIN'
        git config --global init.defaultBranch main
    "
    
    # Chuyen sang user app de build
    sudo -u $APP_USER bash -c "
        cd $APP_DIR
        
        # Cai dat dependencies
        npm install
        
        # Build ung dung
        npm run build
        
        # Tao thu muc logs
        mkdir -p logs
    "
    
    log "Ung dung da duoc build thanh cong"
}

# Tao file environment
create_env_file() {
    log "Tao file cau hinh environment..."
    
    # Tao DATABASE_URL
    DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
    
    # Tao file .env
    sudo -u $APP_USER bash -c "cat > $APP_DIR/.env << EOF
NODE_ENV=production
PORT=3000
DATABASE_URL=$DATABASE_URL
SESSION_SECRET=$SESSION_SECRET
EOF"
    
    log "File .env da duoc tao"
}

# Push database schema
setup_database_schema() {
    log "Thiet lap schema database..."
    
    sudo -u $APP_USER bash -c "
        cd $APP_DIR
        npm run db:push
    "
    
    log "Database schema da duoc thiet lap"
}

# Cau hinh PM2
configure_pm2() {
    log "Cau hinh PM2..."
    
    # Start ung dung voi PM2
    sudo -u $APP_USER bash -c "
        cd $APP_DIR
        pm2 start ecosystem.config.js --env production
        pm2 save
        pm2 startup
    "
    
    # Cau hinh PM2 startup cho system
    sudo env PATH=\$PATH:/usr/bin /home/$APP_USER/.npm-global/bin/pm2 startup systemd -u $APP_USER --hp /home/$APP_USER
    
    log "PM2 da duoc cau hinh"
}

# Cau hinh Nginx
configure_nginx() {
    log "Cau hinh Nginx..."
    
    # Tao file cau hinh site
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
    
    # SSL configuration (se duoc cap nhat boi Certbot)
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
    
    # Test cau hinh
    sudo nginx -t
    
    log "Nginx da duoc cau hinh"
}

# Cai dat SSL voi Let's Encrypt
install_ssl() {
    log "Cai dat SSL certificate..."
    
    # Cai dat Certbot
    sudo apt install -y certbot python3-certbot-nginx
    
    # Tam thoi tat SSL trong cau hinh Nginx de co the lay certificate
    sudo sed -i '/ssl_certificate/d' /etc/nginx/sites-available/$APP_NAME
    sudo sed -i 's/listen 443 ssl http2;/listen 443;/' /etc/nginx/sites-available/$APP_NAME
    sudo systemctl reload nginx
    
    # Lay certificate
    sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --email $SSL_EMAIL --agree-tos --non-interactive --redirect
    
    log "SSL certificate da duoc cai dat"
}

# Cau hinh firewall
configure_firewall() {
    log "Cau hinh firewall..."
    
    sudo ufw --force enable
    sudo ufw allow ssh
    sudo ufw allow 'Nginx Full'
    sudo ufw allow 80
    sudo ufw allow 443
    
    log "Firewall da duoc cau hinh"
}

# Tao script backup database
create_backup_script() {
    log "Tao script backup database..."
    
    sudo tee /usr/local/bin/backup-chatapp-db.sh << EOF
#!/bin/bash
BACKUP_DIR="/home/$APP_USER/backups"
DATE=\$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="\$BACKUP_DIR/chatapp_db_\$DATE.sql"

mkdir -p \$BACKUP_DIR

sudo -u postgres pg_dump $DB_NAME > \$BACKUP_FILE
gzip \$BACKUP_FILE

# Xoa backup cu hon 7 ngay
find \$BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "Database backup completed: \$BACKUP_FILE.gz"
EOF
    
    sudo chmod +x /usr/local/bin/backup-chatapp-db.sh
    
    # Tao cron job backup hang ngay
    (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-chatapp-db.sh") | crontab -
    
    log "Script backup da duoc tao"
}

# Tao script restart ung dung
create_restart_script() {
    log "Tao script quan ly ung dung..."
    
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
    
    log "Script quan ly ung dung da duoc tao"
}

# Tao user admin mac dinh
create_admin_user() {
    log "Tao user admin mac dinh..."
    
    # Tao script tao admin user
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
    
    # Chay script tao admin
    sudo -u $APP_USER bash -c "cd $APP_DIR && node create-admin.js"
    
    # Xoa script sau khi su dung
    sudo rm $APP_DIR/create-admin.js
    
    log "User admin da duoc tao"
}

# Kiem tra trang thai dich vu
check_services() {
    log "Kiem tra trang thai cac dich vu..."
    
    # Kiem tra PostgreSQL
    if sudo systemctl is-active --quiet postgresql; then
        echo -e "${GREEN}✓ PostgreSQL dang hoat dong${NC}"
    else
        echo -e "${RED}✗ PostgreSQL khong hoat dong${NC}"
    fi
    
    # Kiem tra Nginx
    if sudo systemctl is-active --quiet nginx; then
        echo -e "${GREEN}✓ Nginx dang hoat dong${NC}"
    else
        echo -e "${RED}✗ Nginx khong hoat dong${NC}"
    fi
    
    # Kiem tra ung dung
    if sudo -u $APP_USER bash -c "cd $APP_DIR && pm2 list | grep -q online"; then
        echo -e "${GREEN}✓ Ung dung Chat dang hoat dong${NC}"
    else
        echo -e "${RED}✗ Ung dung Chat khong hoat dong${NC}"
    fi
    
    # Test ket noi HTTP
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|301\|302"; then
        echo -e "${GREEN}✓ Ung dung phan hoi HTTP${NC}"
    else
        echo -e "${RED}✗ Ung dung khong phan hoi HTTP${NC}"
    fi
}

# Hien thi thong tin hoan thanh
show_completion_info() {
    echo -e "\n${GREEN}==================== TRIEN KHAI HOAN THANH ====================${NC}"
    echo -e "${GREEN}✓ He thong Real-time Chat da duoc trien khai thanh cong!${NC}\n"
    
    echo -e "${BLUE}Thong tin truy cap:${NC}"
    echo -e "  • Website: https://$DOMAIN"
    echo -e "  • Admin Panel: https://$DOMAIN (dang nhap voi admin/admin123)"
    echo -e "  • Widget JS: https://$DOMAIN/widget.js"
    echo -e "  • Widget CSS: https://$DOMAIN/widget.css"
    
    echo -e "\n${BLUE}Thong tin dang nhap admin mac dinh:${NC}"
    echo -e "  • Username: admin"
    echo -e "  • Password: admin123"
    echo -e "  • ${YELLOW}⚠️  Vui long doi mat khau sau khi dang nhap lan dau${NC}"
    
    echo -e "\n${BLUE}Lenh quan ly he thong:${NC}"
    echo -e "  • Khoi dong: sudo /usr/local/bin/chatapp-control.sh start"
    echo -e "  • Dung: sudo /usr/local/bin/chatapp-control.sh stop"
    echo -e "  • Restart: sudo /usr/local/bin/chatapp-control.sh restart"
    echo -e "  • Xem trang thai: sudo /usr/local/bin/chatapp-control.sh status"
    echo -e "  • Xem logs: sudo /usr/local/bin/chatapp-control.sh logs"
    echo -e "  • Cap nhat: sudo /usr/local/bin/chatapp-control.sh update"
    
    echo -e "\n${BLUE}Tich hop Widget vao website:${NC}"
    echo -e "  Them code sau vao trang web cua ban:"
    echo -e "${YELLOW}  <link rel=\"stylesheet\" href=\"https://$DOMAIN/widget.css\">"
    echo -e "  <script src=\"https://$DOMAIN/widget.js\"></script>"
    echo -e "  <script>"
    echo -e "    window.LiveChatConfig = {"
    echo -e "      domain: '$DOMAIN',"
    echo -e "      position: 'bottom-right',"
    echo -e "      primaryColor: '#007bff',"
    echo -e "      title: 'Ho tro khach hang'"
    echo -e "    };"
    echo -e "  </script>${NC}"
    
    echo -e "\n${BLUE}Thu muc va file quan trong:${NC}"
    echo -e "  • Ung dung: $APP_DIR"
    echo -e "  • Logs: $APP_DIR/logs/"
    echo -e "  • Backup: /home/$APP_USER/backups/"
    echo -e "  • Nginx config: /etc/nginx/sites-available/$APP_NAME"
    echo -e "  • SSL certificates: /etc/letsencrypt/live/$DOMAIN/"
    
    echo -e "\n${GREEN}==================== TRIEN KHAI THANH CONG ====================${NC}"
}

# Ham main
main() {
    echo -e "${BLUE}"
    echo "============================================================================"
    echo "    REAL-TIME CHAT SYSTEM - SCRIPT TRIEN KHAI TU DONG"
    echo "    Phien ban: 1.0"
    echo "    He dieu hanh: Ubuntu 20.04 LTS"
    echo "============================================================================"
    echo -e "${NC}"
    
    # Kiem tra dieu kien
    check_root
    check_os
    
    # Thu thap thong tin
    gather_info
    
    echo -e "\n${BLUE}Bat dau qua trinh trien khai...${NC}"
    
    # Thuc hien cac buoc trien khai
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
    
    # Restart cac dich vu
    sudo systemctl restart nginx
    sudo -u $APP_USER bash -c "cd $APP_DIR && pm2 restart all"
    
    # Kiem tra trang thai
    sleep 5
    check_services
    
    # Hien thi thong tin hoan thanh
    show_completion_info
}

# Chay script
main "$@"