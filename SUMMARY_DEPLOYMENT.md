# TÓM TẮT HƯỚNG DẪN DEPLOYMENT

## 🚀 3 Lệnh Nhanh để Deploy

```bash
# Bước 1: Kiểm tra files
./check-deploy-files.sh

# Bước 2: Kiểm tra VPS
./check-requirements.sh

# Bước 3: Deploy ngay
./deploy-all-in-one.sh
```

## 📋 Checklist Trước Khi Deploy

### ✅ Chuẩn Bị VPS
- [ ] Ubuntu 20.04 LTS
- [ ] RAM >= 2GB, SSD >= 20GB
- [ ] Quyền sudo
- [ ] Kết nối internet ổn định

### ✅ Chuẩn Bị Domain
- [ ] Domain đã mua (ví dụ: `chat.yoursite.com`)
- [ ] DNS Record A trỏ về IP VPS
- [ ] Đợi 5-10 phút để DNS propagate

### ✅ Chuẩn Bị Thông Tin
- [ ] Email để đăng ký SSL (ví dụ: `admin@yoursite.com`)
- [ ] Database password mạnh (ít nhất 12 ký tự)
- [ ] Session secret (ít nhất 32 ký tự ngẫu nhiên)

## 🔥 Deploy Nhanh (Cho Người Vội)

```bash
# Upload files lên VPS
scp -r . user@vps-ip:/home/user/chat-system/
ssh user@vps-ip
cd chat-system

# Deploy one-line
chmod +x *.sh && ./deploy-all-in-one.sh
```

## 📖 Hướng Dẫn Chi Tiết

| File | Mục Đích |
|------|----------|
| `quick-deploy-guide.sh` | Hướng dẫn 5 bước nhanh |
| `HUONG_DAN_SU_DUNG_DEPLOY.md` | Hướng dẫn chi tiết đầy đủ |
| `check-deploy-files.sh` | Kiểm tra files đầy đủ |
| `check-requirements.sh` | Kiểm tra VPS đủ yêu cầu |
| `deploy-all-in-one.sh` | Script deploy chính |
| `deployment.config.sh` | Cấu hình có thể tùy chỉnh |

## ⚡ Quá Trình Deploy

1. **Thu thập thông tin** (2 phút)
2. **Cài đặt hệ thống** (20-30 phút)
3. **Cấu hình SSL** (2-3 phút)
4. **Hoàn thành** ✅

**Tổng thời gian: 25-35 phút**

## 🎯 Kết Quả Sau Deploy

### Truy Cập Website
- **Trang chủ**: `https://yourdomain.com`
- **Admin login**: `https://yourdomain.com/auth`
- **Demo widget**: `https://yourdomain.com/widget-demo`

### Thông Tin Đăng Nhập Mặc Định
```
Username: admin
Password: admin123
```
**⚠️ QUAN TRỌNG: Đổi mật khẩu ngay sau khi đăng nhập!**

### Widget Integration
Thêm vào website khách hàng:
```html
<script>
window.LiveChatConfig = {
  title: 'Hỗ Trợ Khách Hàng',
  primaryColor: '#3b82f6',
  position: 'bottom-right'
};
</script>
<script src="https://yourdomain.com/widget.js"></script>
<link rel="stylesheet" href="https://yourdomain.com/widget.css">
```

## 🛠️ Scripts Quản Lý Hữu Ích

```bash
# Kiểm tra trạng thái
sudo systemctl status nginx postgresql
pm2 status chatapp

# Xem logs
pm2 logs chatapp
sudo journalctl -u nginx -f

# Restart dịch vụ
pm2 restart chatapp
sudo systemctl restart nginx

# Backup database
/usr/local/bin/backup-chatapp-db.sh

# Cập nhật SSL certificate
sudo certbot renew
```

## 🔧 Troubleshooting Nhanh

### Domain chưa trỏ đúng
```bash
# Kiểm tra DNS
nslookup yourdomain.com
dig yourdomain.com A
```

### SSL certificate lỗi
```bash
# Tạo lại SSL
sudo certbot --nginx -d yourdomain.com --force-renewal
```

### Database không kết nối được
```bash
# Kiểm tra PostgreSQL
sudo systemctl status postgresql
sudo -u postgres psql -l
```

### Ứng dụng không chạy
```bash
# Kiểm tra PM2
pm2 status
pm2 restart chatapp
pm2 logs chatapp --lines 50
```

## 📞 Hỗ Trợ

Nếu gặp vấn đề:
1. Kiểm tra logs: `pm2 logs chatapp`
2. Xem file log: `tail -f deploy.log`
3. Kiểm tra status: `sudo systemctl status nginx postgresql`

## ⚠️ Lưu Ý Bảo Mật

- **Đổi mật khẩu admin** ngay sau deploy
- **Backup database** thường xuyên (tự động hàng ngày)
- **Update hệ thống** định kỳ
- **Không chia sẻ** database password và session secret