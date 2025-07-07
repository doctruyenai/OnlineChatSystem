# Huong Dan Deploy Truc Tiep Tu GitHub

## 🚀 Deploy Nhanh Tu GitHub (1 Lenh)

Ban co the deploy truc tiep tu GitHub repository ma khong can download code ve may:

```bash
# Tai va chay script deploy tu GitHub
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github.sh | bash
```

**HOAC**

```bash
# Tai script truoc, sau do chay
wget https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github.sh
chmod +x deploy-from-github.sh
./deploy-from-github.sh
```

## 📋 Cach Hoat Dong

Script `deploy-from-github.sh` se:

1. **Tu dong clone** code tu GitHub repository cua ban
2. **Chay script deploy** chinh (`deploy-all-in-one.sh`)
3. **Tu dong cleanup** sau khi hoan thanh

## 🔧 Repository Mac Dinh

Script duoc cau hinh san voi repository:
```
https://github.com/doctruyenai/OnlineChatSystem
```

Ban co the thay doi trong qua trinh deploy hoac sua trong script.

## ✅ Yeu Cau

- **VPS Ubuntu 20.04+** voi quyen sudo
- **Ket noi internet** de clone tu GitHub
- **Domain** da tro ve IP VPS
- **Thong tin can thiet**:
  - Email cho SSL certificate
  - Database password
  - Session secret

## ⚡ Quy Trinh Deploy

### Buoc 1: Chay Script
```bash
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github.sh | bash
```

### Buoc 2: Nhap Thong Tin
Script se hoi:
- GitHub repository URL (co the de trong dung mac dinh)
- Domain name
- Email cho SSL
- Database password
- Session secret

### Buoc 3: Cho Deploy Hoan Thanh
- Thoi gian: 25-35 phut
- Tu dong cai dat tat ca dependencies
- Tu dong cau hinh SSL va firewall

## 🎯 Ket Qua

Sau khi deploy xong:
- **Website**: `https://yourdomain.com`
- **Admin**: `https://yourdomain.com/auth`
- **Login**: `admin/admin123` ⚠️ **DOI NGAY!**

## 🔄 Update He Thong

De update tu GitHub sau khi da deploy:

```bash
# Su dung script quan ly co san
sudo /usr/local/bin/chatapp-control.sh update
```

Script nay se:
1. Dung ung dung
2. Pull code moi tu GitHub
3. Cai dat dependencies moi
4. Build lai ung dung
5. Update database schema
6. Khoi dong lai ung dung

## 🛠️ Scripts Co San Sau Deploy

```bash
# Quan ly ung dung
sudo /usr/local/bin/chatapp-control.sh start|stop|restart|status|logs|update

# Backup database
sudo /usr/local/bin/backup-chatapp-db.sh

# Kiem tra status
sudo systemctl status nginx postgresql
pm2 status
```

## 📚 So Sanh Cac Phuong Phap Deploy

| Phuong Phap | Uu Diem | Nhuoc Diem | Thoi Gian |
|-------------|---------|------------|-----------|
| **Deploy tu GitHub** | Khong can download code, luon moi nhat | Can internet trong qua trinh deploy | 25-35 phut |
| **Deploy tu local** | Co the customize code truoc | Phai download/upload code | 20-30 phut |

## 🔒 Bao Mat

- Script chi clone tu repository public
- Khong luu tru credentials
- Tu dong cleanup thu muc tam
- Su dung HTTPS cho clone

## ❓ Troubleshooting

### Repository khong clone duoc
```bash
# Kiem tra ket noi internet
ping github.com

# Kiem tra Git
git --version
```

### Script khong tim thay
Dam bao repository co files:
- `deploy-all-in-one.sh`
- `package.json`
- Cac script khac can thiet

### Deploy fail
```bash
# Xem logs
tail -f /tmp/deploy.log

# Kiem tra VPS requirements
./check-requirements.sh
```

## 🚀 Lenh Deploy Nhanh Nhat

```bash
# One-liner deploy tu GitHub
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github.sh | bash
```

Chi can 1 lenh va cung cap thong tin khi duoc hoi!