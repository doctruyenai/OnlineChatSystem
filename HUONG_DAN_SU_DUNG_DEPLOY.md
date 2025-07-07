# Huong Dan Su Dung Script Deploy All-in-One

## Tong Quan

Script `deploy-all-in-one.sh` la cong cu tu dong hoa hoan toan viec trien khai he thong Real-time Chat System len VPS Ubuntu 20.04. Script nay se tu dong cai dat va cau hinh tat ca cac thanh phan can thiet.

## Yeu Cau He Thong

### VPS Requirements
- **He dieu hanh**: Ubuntu 20.04 LTS
- **RAM**: Toi thieu 2GB (khuyen nghi 4GB+)
- **CPU**: Toi thieu 1 core (khuyen nghi 2+ cores)
- **O cung**: Toi thieu 20GB SSD
- **Ket noi**: Quyen sudo va ket noi internet on dinh

### Thong Tin Can Chuan Bi
- **Domain name** da tro ve IP VPS (vi du: `chat.example.com`)
- **Email address** de dang ky SSL certificate
- **Database password** (manh, it nhat 12 ky tu)
- **Session secret** (it nhat 32 ky tu ngau nhien)

## Huong Dan Tung Buoc

### Buoc 1: Chuan Bi Files
```bash
# Upload tat ca files len VPS
scp -r . user@your-vps-ip:/home/user/chat-deployment/
ssh user@your-vps-ip
cd chat-deployment
```

### Buoc 2: Cap Quyen Thuc Thi
```bash
# Chay setup script de cap quyen
./setup-deployment.sh
```

### Buoc 3: Kiem Tra Yeu Cau He Thong
```bash
# Kiem tra VPS co du yeu cau khong
./check-requirements.sh
```

**Ket qua mong doi:**
- ✓ He dieu hanh Ubuntu 20.04
- ✓ RAM >= 2GB
- ✓ O cung con >= 10GB
- ✓ Quyen sudo
- ✓ Ket noi internet

### Buoc 4: (Tuy Chon) Tuy Chinh Cau Hinh
```bash
# Xem cau hinh hien tai
./deployment.config.sh show

# Chinh sua cau hinh neu can
nano deployment.config.sh

# Kiem tra cau hinh sau khi chinh sua
./deployment.config.sh validate
```

### Buoc 5: Chay Deploy Script
```bash
# Chay script trien khai chinh
./deploy-all-in-one.sh
```

## Qua Trinh Trien Khai

### Giai Doan 1: Thu Thap Thong Tin
Script se hoi ban:

1. **Domain name**:
   ```
   Nhap domain name (vi du: example.com): chat.yoursite.com
   ```

2. **Email cho SSL**:
   ```
   Nhap email cho SSL certificate: admin@yoursite.com
   ```

3. **Database password**:
   ```
   Nhap mat khau cho database PostgreSQL: [nhap password manh]
   ```

4. **Session secret**:
   ```
   Nhap session secret (it nhat 32 ky tu): [nhap chuoi ngau nhien dai]
   ```

### Giai Doan 2: Cai Dat Tu Dong
Script se tu dong thuc hien:

1. **Cap nhat he thong** (5-10 phut)
2. **Cai dat Node.js 20.x** (2-3 phut)
3. **Cai dat PostgreSQL 14** (3-5 phut)
4. **Cai dat Nginx** (1-2 phut)
5. **Cai dat PM2** (1 phut)
6. **Tao user va database** (1 phut)
7. **Deploy ung dung** (5-10 phut)
8. **Cau hinh SSL certificate** (2-3 phut)
9. **Thiet lap firewall** (1 phut)
10. **Cau hinh backup tu dong** (1 phut)

**Tong thoi gian**: 20-35 phut

### Giai Doan 3: Xac Nhan Thanh Cong
Sau khi hoan thanh, ban se thay:
```
============================================================================
    TRIEN KHAI THANH CONG!
============================================================================

🎉 He thong da duoc trien khai thanh cong tai:
   Website: https://chat.yoursite.com
   Admin Panel: https://chat.yoursite.com/auth

🔐 Thong tin dang nhap mac dinh:
   Username: admin
   Password: admin123

📁 Widget Integration:
   Script: https://chat.yoursite.com/widget.js
   Style: https://chat.yoursite.com/widget.css

🛠️ Scripts quan ly:
   Kiem tra status: sudo systemctl status chatapp
   Xem logs: pm2 logs chatapp
   Restart: pm2 restart chatapp
   Backup DB: /usr/local/bin/backup-chatapp-db.sh
```

## Xu Ly Loi Thuong Gap

### Loi Domain Chua Tro Dung
```
ERROR: Domain chua tro ve IP server nay
```
**Giai phap**: Kiem tra DNS record A cua domain tro ve IP VPS

### Loi Quyen Sudo
```
ERROR: User khong co quyen sudo
```
**Giai phap**: 
```bash
su - root
usermod -aG sudo your-username
```

### Loi Port Da Duoc Su Dung
```
ERROR: Port 80/443 dang duoc su dung
```
**Giai phap**:
```bash
sudo systemctl stop apache2  # Neu co Apache
sudo systemctl disable apache2
```

### Loi SSL Certificate
```
ERROR: Khong the tao SSL certificate
```
**Giai phap**: 
- Kiem tra domain da tro dung IP
- Doi 5-10 phut de DNS propagate
- Chay lai: `sudo certbot --nginx -d yourdomain.com`

## Sau Khi Deploy

### Dang Nhap He Thong
1. Truy cap `https://yourdomain.com/auth`
2. Dang nhap voi `admin/admin123`
3. **Doi mat khau ngay lap tuc**

### Tich Hop Widget
Them vao website khach hang:
```html
<script>
window.LiveChatConfig = {
  title: 'Ho Tro Khach Hang',
  subtitle: 'Chung toi san sang ho tro ban',
  primaryColor: '#3b82f6',
  position: 'bottom-right'
};
</script>
<script src="https://yourdomain.com/widget.js"></script>
<link rel="stylesheet" href="https://yourdomain.com/widget.css">
```

### Scripts Quan Ly Huu Ich
```bash
# Kiem tra trang thai cac dich vu
sudo systemctl status nginx postgresql pm2-chatapp

# Xem logs ung dung
pm2 logs chatapp

# Restart ung dung
pm2 restart chatapp

# Backup database
/usr/local/bin/backup-chatapp-db.sh

# Restore database
/usr/local/bin/restore-chatapp-db.sh backup-file.sql

# Kiem tra tinh trang SSL
sudo certbot certificates
```

### Monitoring va Bao Tri
- **Backup tu dong**: Chay hang ngay luc 2:00 AM
- **Log rotation**: Tu dong cleanup logs cu
- **SSL renewal**: Tu dong gia han SSL certificate
- **Security updates**: Kiem tra va update dinh ky

## Lien He Ho Tro

Neu gap van de trong qua trinh deploy:
1. Kiem tra logs: `sudo journalctl -u nginx -f`
2. Kiem tra PM2: `pm2 logs`
3. Xem file log deploy: `tail -f deploy.log`

## Luu Y An Toan

- **Doi mat khau mac dinh** ngay sau khi deploy
- **Backup thuong xuyen** du lieu quan trong
- **Update he thong** dinh ky
- **Monitor logs** de phat hien bat thuong
- **Khong chia se** thong tin database va session secret