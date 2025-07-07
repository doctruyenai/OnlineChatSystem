# Hướng dẫn triển khai Real-time Chat System lên VPS Ubuntu 20.04

## Yêu cầu hệ thống

### Phần cứng tối thiểu:
- RAM: 2GB (khuyến nghị 4GB)
- CPU: 2 cores
- Storage: 20GB SSD
- Bandwidth: 100Mbps

### Phần mềm:
- Ubuntu 20.04 LTS
- Node.js 20.x
- PostgreSQL 14+
- Nginx
- PM2 (Process Manager)
- Certbot (SSL Certificate)

## Bước 1: Chuẩn bị VPS

### 1.1. Cập nhật hệ thống
```bash
sudo apt update && sudo apt upgrade -y
```

### 1.2. Cài đặt các packages cần thiết
```bash
sudo apt install -y curl wget git ufw nginx postgresql postgresql-contrib
```

### 1.3. Tạo user mới (không dùng root)
```bash
# Tạo user cho ứng dụng
sudo adduser chatapp
sudo usermod -aG sudo chatapp

# Chuyển sang user mới
su - chatapp
```

## Bước 2: Cài đặt Node.js

### 2.1. Cài đặt Node.js 20.x
```bash
# Thêm NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Cài đặt Node.js
sudo apt-get install -y nodejs

# Kiểm tra phiên bản
node --version  # Phải là v20.x.x
npm --version
```

### 2.2. Cài đặt PM2 (Process Manager)
```bash
sudo npm install -g pm2
```

## Bước 3: Cấu hình PostgreSQL

### 3.1. Tạo database và user
```bash
sudo -u postgres psql

-- Trong PostgreSQL console:
CREATE DATABASE chatapp_db;
CREATE USER chatapp_user WITH ENCRYPTED PASSWORD 'your_strong_password_here';
GRANT ALL PRIVILEGES ON DATABASE chatapp_db TO chatapp_user;

-- Cấp quyền tạo extension
ALTER USER chatapp_user CREATEDB;
\q
```

### 3.2. Cấu hình PostgreSQL cho remote connection
```bash
# Chỉnh sửa postgresql.conf
sudo nano /etc/postgresql/12/main/postgresql.conf

# Tìm và sửa dòng này:
listen_addresses = 'localhost'

# Chỉnh sửa pg_hba.conf
sudo nano /etc/postgresql/12/main/pg_hba.conf

# Thêm dòng này:
local   all             chatapp_user                            md5
```

### 3.3. Restart PostgreSQL
```bash
sudo systemctl restart postgresql
sudo systemctl enable postgresql
```

## Bước 4: Deploy ứng dụng

### 4.1. Clone source code
```bash
cd /home/chatapp
git clone https://github.com/your-username/chat-system.git
cd chat-system
```

### 4.2. Cài đặt dependencies
```bash
npm install
```

### 4.3. Tạo file environment
```bash
cp .env.example .env
nano .env
```

**Nội dung file .env:**
```env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://chatapp_user:your_strong_password_here@localhost:5432/chatapp_db
SESSION_SECRET=your_very_long_random_session_secret_here_at_least_64_characters
```

### 4.4. Build ứng dụng
```bash
npm run build
```

### 4.5. Chạy database migrations
```bash
npm run db:push
```

### 4.6. Tạo admin account (tùy chọn)
```bash
node -e "
const crypto = require('crypto');
const { promisify } = require('util');
const scryptAsync = promisify(crypto.scrypt);

async function createAdmin() {
  const password = 'admin123456';
  const salt = crypto.randomBytes(16).toString('hex');
  const buf = await scryptAsync(password, salt, 64);
  const hashedPassword = buf.toString('hex') + '.' + salt;
  
  console.log('INSERT INTO users (username, email, password, first_name, last_name, role, is_online) VALUES');
  console.log(\`('admin@example.com', 'admin@example.com', '\${hashedPassword}', 'Admin', 'User', 'admin', false);\`);
}

createAdmin();
"
```

## Bước 5: Cấu hình PM2

### 5.1. Tạo file ecosystem.config.js
```bash
nano ecosystem.config.js
```

**Nội dung file:**
```javascript
module.exports = {
  apps: [{
    name: 'chat-system',
    script: 'dist/index.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
}
```

### 5.2. Tạo thư mục logs
```bash
mkdir logs
```

### 5.3. Start ứng dụng với PM2
```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## Bước 6: Cấu hình Nginx

### 6.1. Tạo file cấu hình Nginx
```bash
sudo nano /etc/nginx/sites-available/chatapp
```

**Nội dung file:**
```nginx
upstream chatapp {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # WebSocket support
    location /ws {
        proxy_pass http://chatapp;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
    }

    # API routes
    location /api {
        proxy_pass http://chatapp;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files
    location / {
        proxy_pass http://chatapp;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Widget files
    location ~ ^/(widget\.js|widget\.css)$ {
        proxy_pass http://chatapp;
        proxy_set_header Host $host;
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
        add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range";
    }
}
```

### 6.2. Enable site
```bash
sudo ln -s /etc/nginx/sites-available/chatapp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

## Bước 7: Cấu hình SSL với Let's Encrypt

### 7.1. Cài đặt Certbot
```bash
sudo apt install certbot python3-certbot-nginx
```

### 7.2. Lấy SSL certificate
```bash
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

### 7.3. Tự động renew certificate
```bash
sudo crontab -e

# Thêm dòng này:
0 12 * * * /usr/bin/certbot renew --quiet
```

## Bước 8: Cấu hình Firewall

### 8.1. Cấu hình UFW
```bash
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

### 8.2. Kiểm tra status
```bash
sudo ufw status
```

## Bước 9: Monitoring và Maintenance

### 9.1. Xem logs ứng dụng
```bash
# PM2 logs
pm2 logs

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 9.2. Restart services
```bash
# Restart ứng dụng
pm2 restart chat-system

# Restart Nginx
sudo systemctl restart nginx

# Restart PostgreSQL
sudo systemctl restart postgresql
```

### 9.3. Update ứng dụng
```bash
cd /home/chatapp/chat-system
git pull origin main
npm install
npm run build
pm2 restart chat-system
```

## Bước 10: Widget Integration

### 10.1. Cấu hình CORS cho widget
Đảm bảo widget có thể load từ các domain khác nhau bằng cách thêm headers trong Nginx config (đã có trong config trên).

### 10.2. Test widget integration
Tạo file test HTML:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Widget Test</title>
</head>
<body>
    <h1>Test Page</h1>
    
    <!-- Widget Integration -->
    <script>
      window.LiveChatConfig = {
        domain: "your-domain.com",
        title: "Hỗ trợ khách hàng",
        subtitle: "Chúng tôi sẵn sàng hỗ trợ bạn",
        primaryColor: "#3b82f6",
        position: "bottom-right",
        welcomeMessage: "Xin chào! Chúng tôi có thể giúp gì cho bạn?",
        offlineMessage: "Hiện tại chúng tôi đang offline. Vui lòng để lại tin nhắn.",
        showAgentPhotos: true,
        allowFileUpload: true,
        collectUserInfo: true,
        requiredFields: ["name", "email"]
      };
    </script>
    <script src="https://your-domain.com/widget.js"></script>
    <link rel="stylesheet" href="https://your-domain.com/widget.css">
</body>
</html>
```

## Troubleshooting

### Lỗi thường gặp:

1. **Ứng dụng không start được:**
   ```bash
   pm2 logs chat-system
   ```

2. **Database connection error:**
   ```bash
   sudo -u postgres psql -c "SELECT version();"
   ```

3. **Nginx 502 Bad Gateway:**
   ```bash
   sudo nginx -t
   sudo systemctl status nginx
   ```

4. **WebSocket không hoạt động:**
   Kiểm tra Nginx config có hỗ trợ WebSocket upgrade chưa.

### Performance tuning:

1. **Tăng file limits:**
   ```bash
   echo "fs.file-max = 65536" | sudo tee -a /etc/sysctl.conf
   ```

2. **PostgreSQL tuning:**
   ```bash
   sudo nano /etc/postgresql/12/main/postgresql.conf
   
   # Tăng shared_buffers, work_mem, max_connections
   ```

3. **PM2 monitoring:**
   ```bash
   pm2 install pm2-server-monit
   ```

## Bảo mật

### Checklist bảo mật:
- [ ] Đổi default passwords
- [ ] Cấu hình firewall
- [ ] Enable SSL/TLS
- [ ] Regular updates
- [ ] Backup database
- [ ] Monitor logs
- [ ] Disable root login
- [ ] Use SSH keys thay vì password

### Backup database:
```bash
# Backup
pg_dump -h localhost -U chatapp_user chatapp_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore
psql -h localhost -U chatapp_user chatapp_db < backup_file.sql
```

## Hỗ trợ

Nếu gặp vấn đề trong quá trình triển khai, hãy kiểm tra:
1. Logs của PM2: `pm2 logs`
2. Logs của Nginx: `sudo tail -f /var/log/nginx/error.log`
3. Logs của PostgreSQL: `sudo tail -f /var/log/postgresql/postgresql-12-main.log`
4. System logs: `sudo journalctl -f`

Chúc bạn triển khai thành công!