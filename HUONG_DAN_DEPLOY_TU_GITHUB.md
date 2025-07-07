# Hướng Dẫn Deploy Trực Tiếp Từ GitHub

## 🚀 Deploy Nhanh Từ GitHub (1 Lệnh)

Bạn có thể deploy trực tiếp từ GitHub repository mà không cần download code về máy:

```bash
# Tải và chạy script deploy từ GitHub
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github.sh | bash
```

**HOẶC**

```bash
# Tải script trước, sau đó chạy
wget https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github.sh
chmod +x deploy-from-github.sh
./deploy-from-github.sh
```

## 📋 Cách Hoạt Động

Script `deploy-from-github.sh` sẽ:

1. **Tự động clone** code từ GitHub repository của bạn
2. **Chạy script deploy** chính (`deploy-all-in-one.sh`)
3. **Tự động cleanup** sau khi hoàn thành

## 🔧 Repository Mặc Định

Script được cấu hình sẵn với repository:
```
https://github.com/doctruyenai/OnlineChatSystem
```

Bạn có thể thay đổi trong quá trình deploy hoặc sửa trong script.

## ✅ Yêu Cầu

- **VPS Ubuntu 20.04+** với quyền sudo
- **Kết nối internet** để clone từ GitHub
- **Domain** đã trỏ về IP VPS
- **Thông tin cần thiết**:
  - Email cho SSL certificate
  - Database password
  - Session secret

## ⚡ Quy Trình Deploy

### Bước 1: Chạy Script
```bash
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github.sh | bash
```

### Bước 2: Nhập Thông Tin
Script sẽ hỏi:
- GitHub repository URL (có thể để trống dùng mặc định)
- Domain name
- Email cho SSL
- Database password
- Session secret

### Bước 3: Chờ Deploy Hoàn Thành
- Thời gian: 25-35 phút
- Tự động cài đặt tất cả dependencies
- Tự động cấu hình SSL và firewall

## 🎯 Kết Quả

Sau khi deploy xong:
- **Website**: `https://yourdomain.com`
- **Admin**: `https://yourdomain.com/auth`
- **Login**: `admin/admin123` ⚠️ **ĐỔI NGAY!**

## 🔄 Update Hệ Thống

Để update từ GitHub sau khi đã deploy:

```bash
# Sử dụng script quản lý có sẵn
sudo /usr/local/bin/chatapp-control.sh update
```

Script này sẽ:
1. Dừng ứng dụng
2. Pull code mới từ GitHub
3. Cài đặt dependencies mới
4. Build lại ứng dụng
5. Update database schema
6. Khởi động lại ứng dụng

## 🛠️ Scripts Có Sẵn Sau Deploy

```bash
# Quản lý ứng dụng
sudo /usr/local/bin/chatapp-control.sh start|stop|restart|status|logs|update

# Backup database
sudo /usr/local/bin/backup-chatapp-db.sh

# Kiểm tra status
sudo systemctl status nginx postgresql
pm2 status
```

## 📚 So Sánh Các Phương Pháp Deploy

| Phương Pháp | Ưu Điểm | Nhược Điểm | Thời Gian |
|-------------|---------|------------|-----------|
| **Deploy từ GitHub** | Không cần download code, luôn mới nhất | Cần internet trong quá trình deploy | 25-35 phút |
| **Deploy từ local** | Có thể customize code trước | Phải download/upload code | 20-30 phút |

## 🔒 Bảo Mật

- Script chỉ clone từ repository public
- Không lưu trữ credentials
- Tự động cleanup thư mục tạm
- Sử dụng HTTPS cho clone

## ❓ Troubleshooting

### Repository không clone được
```bash
# Kiểm tra kết nối internet
ping github.com

# Kiểm tra Git
git --version
```

### Script không tìm thấy
Đảm bảo repository có files:
- `deploy-all-in-one.sh`
- `package.json`
- Các script khác cần thiết

### Deploy fail
```bash
# Xem logs
tail -f /tmp/deploy.log

# Kiểm tra VPS requirements
./check-requirements.sh
```

## 🚀 Lệnh Deploy Nhanh Nhất

```bash
# One-liner deploy từ GitHub
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github.sh | bash
```

Chỉ cần 1 lệnh và cung cấp thông tin khi được hỏi!