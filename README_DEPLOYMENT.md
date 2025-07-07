# DEPLOYMENT GUIDE - REAL-TIME CHAT SYSTEM

## 🚀 DEPLOY NHANH NHAT (1 LENH)

```bash
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github-fixed.sh | bash
```

## ✅ YEU CAU HE THONG

- **VPS Ubuntu 20.04+** voi quyen sudo
- **RAM**: Toi thieu 2GB (khuyen nghi 4GB+)  
- **CPU**: Toi thieu 1 core (khuyen nghi 2+ cores)
- **SSD**: Toi thieu 20GB
- **Domain**: Da tro ve IP VPS
- **Email**: Hop le de dang ky SSL

## 📋 THONG TIN CAN CHUAN BI

- Domain name (vi du: `chat.yoursite.com`)
- Email cho SSL certificate
- Mat khau database manh (12+ ky tu)
- Session secret (32+ ky tu ngau nhien)

## 🔧 2 PHUONG PHAP DEPLOY

### 🌟 Phuong Phap 1: Tu GitHub (Khuyen nghi)
```bash
# Chi can 1 lenh tren VPS
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github-fixed.sh | bash
```

**Uu diem:**
- Khong can download code
- Luon co phien ban moi nhat
- Tu dong setup tat ca

### 📁 Phuong Phap 2: Tu Local Files
```bash
# Upload files len VPS
scp -r . user@vps-ip:/home/user/chat-system/
ssh user@vps-ip
cd chat-system

# Kiem tra va deploy
./check-requirements.sh
./deploy-all-in-one.sh
```

## ⚡ QUA TRINH DEPLOY TU DONG

1. **Kiem tra he thong** - VPS requirements
2. **Cai dat dependencies** - Node.js, PostgreSQL, Nginx, PM2
3. **Clone code** tu GitHub repository  
4. **Build ung dung** - npm install, build
5. **Cau hinh database** - PostgreSQL setup
6. **Cau hinh web server** - Nginx reverse proxy
7. **SSL certificate** - Let's Encrypt tu dong
8. **Firewall setup** - UFW configuration
9. **Backup scripts** - Tu dong tao scripts backup
10. **Start services** - PM2, Nginx, PostgreSQL

## 🎯 KET QUA SAU DEPLOY

- **Website**: https://yourdomain.com
- **Admin Panel**: https://yourdomain.com/auth  
- **Login**: admin/admin123 ⚠️ **DOI NGAY!**
- **Widget Demo**: https://yourdomain.com/widget-demo
- **Widget tich hop**: San sang su dung

## 🔄 QUAN LY SAU DEPLOY

### Cap nhat he thong
```bash
sudo /usr/local/bin/chatapp-control.sh update
```

### Quan ly services
```bash
# Xem trang thai
sudo /usr/local/bin/chatapp-control.sh status

# Restart
sudo /usr/local/bin/chatapp-control.sh restart

# Xem logs
sudo /usr/local/bin/chatapp-control.sh logs
```

### Backup database
```bash
# Backup thu cong
sudo /usr/local/bin/backup-chatapp-db.sh

# Backup tu dong hang ngay luc 2h sang
# Da duoc cau hinh san trong deployment
```

## 🔍 KIEM TRA DEPLOYMENT

### Services status
```bash
pm2 status                      # Chat application
sudo systemctl status nginx    # Web server  
sudo systemctl status postgresql # Database
```

### Website access
- Check website loading: `curl -I https://yourdomain.com`
- Check SSL certificate: Browser should show green lock
- Admin login: https://yourdomain.com/auth

## 🛠️ TROUBLESHOOTING

### Website khong load
```bash
# Kiem tra Nginx
sudo systemctl status nginx
sudo nginx -t

# Kiem tra PM2
pm2 status
pm2 logs
```

### Database loi
```bash
# Kiem tra PostgreSQL
sudo systemctl status postgresql
sudo -u postgres psql -c "\l"
```

### SSL certificate loi
```bash
# Kiem tra certificate
sudo certbot certificates
sudo certbot renew --dry-run
```

### Deploy that bai
```bash
# Kiem tra requirements
./check-requirements.sh

# Kiem tra files
./check-deploy-files.sh

# Clean va deploy lai
sudo /usr/local/bin/chatapp-control.sh stop
./deploy-all-in-one.sh
```

## 📚 TAI LIEU CHI TIET

- `DANH_SACH_FILES_TRIEN_KHAI.md` - Danh sach tat ca files
- `HUONG_DAN_DEPLOY_TU_GITHUB.md` - Chi tiet deploy tu GitHub  
- `HUONG_DAN_SU_DUNG_DEPLOY.md` - Huong dan day du
- `SUMMARY_DEPLOYMENT.md` - Tom tat toan bo

## 🎯 SCRIPTS QUAN TRONG

| Script | Muc dich |
|--------|----------|
| `deploy-from-github-fixed.sh` | **Deploy chinh tu GitHub** |
| `deploy-all-in-one.sh` | Deploy tu local files |
| `check-requirements.sh` | Kiem tra VPS |
| `quick-deploy-guide-fixed.sh` | Huong dan nhanh |

## ⚠️ LUU Y BAO MAT

1. **Doi mat khau admin** ngay sau deploy
2. **Cap nhat he thong** dinh ky
3. **Backup database** thuong xuyen  
4. **Monitor logs** de phat hien van de
5. **SSL renewal** tu dong (certbot)

## 🔗 REPOSITORY

GitHub: https://github.com/doctruyenai/OnlineChatSystem

---

**Deploy ngay bay gio:**
```bash
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github-fixed.sh | bash
```