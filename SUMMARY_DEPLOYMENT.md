# TOM TAT HUONG DAN DEPLOYMENT

## 🚀 Deploy Nhanh Nhat (Tu GitHub)

```bash
# Deploy truc tiep tu GitHub repository (1 lenh)
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github.sh | bash
```

## 📋 Hoac Deploy Tu Local

```bash
# Buoc 1: Kiem tra files
./check-deploy-files.sh

# Buoc 2: Kiem tra VPS
./check-requirements.sh

# Buoc 3: Deploy ngay
./deploy-all-in-one.sh
```

## 📋 Checklist Truoc Khi Deploy

### ✅ Chuan Bi VPS
- [ ] Ubuntu 20.04 LTS
- [ ] RAM >= 2GB, SSD >= 20GB
- [ ] Quyen sudo
- [ ] Ket noi internet on dinh

### ✅ Chuan Bi Domain
- [ ] Domain da mua (vi du: `chat.yoursite.com`)
- [ ] DNS Record A tro ve IP VPS
- [ ] Doi 5-10 phut de DNS propagate

### ✅ Chuan Bi Thong Tin
- [ ] Email de dang ky SSL (vi du: `admin@yoursite.com`)
- [ ] Database password manh (it nhat 12 ky tu)
- [ ] Session secret (it nhat 32 ky tu ngau nhien)

## 🔥 2 Phuong Phap Deploy

### 🌟 Phuong Phap 1: Deploy Tu GitHub (Khuyen Nghi)
```bash
# Chi can 1 lenh tren VPS
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github.sh | bash
```

### 📁 Phuong Phap 2: Deploy Tu Local
```bash
# Upload files len VPS
scp -r . user@vps-ip:/home/user/chat-system/
ssh user@vps-ip
cd chat-system

# Deploy one-line
chmod +x *.sh && ./deploy-all-in-one.sh
```

## 📖 Huong Dan Chi Tiet

| File | Muc Dich |
|------|----------|
| `deploy-from-github.sh` | **Deploy truc tiep tu GitHub** |
| `deploy-all-in-one.sh` | Script deploy chinh |
| `quick-deploy-guide.sh` | Huong dan 5 buoc nhanh |
| `HUONG_DAN_SU_DUNG_DEPLOY.md` | Huong dan chi tiet day du |
| `HUONG_DAN_DEPLOY_TU_GITHUB.md` | **Huong dan deploy tu GitHub** |
| `check-deploy-files.sh` | Kiem tra files day du |
| `check-requirements.sh` | Kiem tra VPS du yeu cau |
| `deployment.config.sh` | Cau hinh co the tuy chinh |

## ⚡ Qua Trinh Deploy

1. **Thu thap thong tin** (2 phut)
2. **Cai dat he thong** (20-30 phut)
3. **Cau hinh SSL** (2-3 phut)
4. **Hoan thanh** ✅

**Tong thoi gian: 25-35 phut**

## 🎯 Ket Qua Sau Deploy

### Truy Cap Website
- **Trang chu**: `https://yourdomain.com`
- **Admin login**: `https://yourdomain.com/auth`
- **Demo widget**: `https://yourdomain.com/widget-demo`

### Thong Tin Dang Nhap Mac Dinh
```
Username: admin
Password: admin123
```
**⚠️ QUAN TRONG: Doi mat khau ngay sau khi dang nhap!**

### Widget Integration
Them vao website khach hang:
```html
<script>
window.LiveChatConfig = {
  title: 'Ho Tro Khach Hang',
  primaryColor: '#3b82f6',
  position: 'bottom-right'
};
</script>
<script src="https://yourdomain.com/widget.js"></script>
<link rel="stylesheet" href="https://yourdomain.com/widget.css">
```

## 🛠️ Scripts Quan Ly Huu Ich

```bash
# Kiem tra trang thai
sudo systemctl status nginx postgresql
pm2 status chatapp

# Xem logs
pm2 logs chatapp
sudo journalctl -u nginx -f

# Restart dich vu
pm2 restart chatapp
sudo systemctl restart nginx

# Backup database
/usr/local/bin/backup-chatapp-db.sh

# Cap nhat SSL certificate
sudo certbot renew
```

## 🔧 Troubleshooting Nhanh

### Domain chua tro dung
```bash
# Kiem tra DNS
nslookup yourdomain.com
dig yourdomain.com A
```

### SSL certificate loi
```bash
# Tao lai SSL
sudo certbot --nginx -d yourdomain.com --force-renewal
```

### Database khong ket noi duoc
```bash
# Kiem tra PostgreSQL
sudo systemctl status postgresql
sudo -u postgres psql -l
```

### Ung dung khong chay
```bash
# Kiem tra PM2
pm2 status
pm2 restart chatapp
pm2 logs chatapp --lines 50
```

## 📞 Ho Tro

Neu gap van de:
1. Kiem tra logs: `pm2 logs chatapp`
2. Xem file log: `tail -f deploy.log`
3. Kiem tra status: `sudo systemctl status nginx postgresql`

## ⚠️ Luu Y Bao Mat

- **Doi mat khau admin** ngay sau deploy
- **Backup database** thuong xuyen (tu dong hang ngay)
- **Update he thong** dinh ky
- **Khong chia se** database password va session secret