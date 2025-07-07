# Hướng Dẫn Sử Dụng Script Deploy All-in-One

## Tổng Quan

Script `deploy-all-in-one.sh` là công cụ tự động hóa hoàn toàn việc triển khai hệ thống Real-time Chat System lên VPS Ubuntu 20.04. Script này sẽ tự động cài đặt và cấu hình tất cả các thành phần cần thiết.

## Yêu Cầu Hệ Thống

### VPS Requirements
- **Hệ điều hành**: Ubuntu 20.04 LTS
- **RAM**: Tối thiểu 2GB (khuyến nghị 4GB+)
- **CPU**: Tối thiểu 1 core (khuyến nghị 2+ cores)
- **Ổ cứng**: Tối thiểu 20GB SSD
- **Kết nối**: Quyền sudo và kết nối internet ổn định

### Thông Tin Cần Chuẩn Bị
- **Domain name** đã trỏ về IP VPS (ví dụ: `chat.example.com`)
- **Email address** để đăng ký SSL certificate
- **Database password** (mạnh, ít nhất 12 ký tự)
- **Session secret** (ít nhất 32 ký tự ngẫu nhiên)

## Hướng Dẫn Từng Bước

### Bước 1: Chuẩn Bị Files
```bash
# Upload tất cả files lên VPS
scp -r . user@your-vps-ip:/home/user/chat-deployment/
ssh user@your-vps-ip
cd chat-deployment
```

### Bước 2: Cấp Quyền Thực Thi
```bash
# Chạy setup script để cấp quyền
./setup-deployment.sh
```

### Bước 3: Kiểm Tra Yêu Cầu Hệ Thống
```bash
# Kiểm tra VPS có đủ yêu cầu không
./check-requirements.sh
```

**Kết quả mong đợi:**
- ✓ Hệ điều hành Ubuntu 20.04
- ✓ RAM >= 2GB
- ✓ Ổ cứng còn >= 10GB
- ✓ Quyền sudo
- ✓ Kết nối internet

### Bước 4: (Tùy Chọn) Tùy Chỉnh Cấu Hình
```bash
# Xem cấu hình hiện tại
./deployment.config.sh show

# Chỉnh sửa cấu hình nếu cần
nano deployment.config.sh

# Kiểm tra cấu hình sau khi chỉnh sửa
./deployment.config.sh validate
```

### Bước 5: Chạy Deploy Script
```bash
# Chạy script triển khai chính
./deploy-all-in-one.sh
```

## Quá Trình Triển Khai

### Giai Đoạn 1: Thu Thập Thông Tin
Script sẽ hỏi bạn:

1. **Domain name**:
   ```
   Nhập domain name (ví dụ: example.com): chat.yoursite.com
   ```

2. **Email cho SSL**:
   ```
   Nhập email cho SSL certificate: admin@yoursite.com
   ```

3. **Database password**:
   ```
   Nhập mật khẩu cho database PostgreSQL: [nhập password mạnh]
   ```

4. **Session secret**:
   ```
   Nhập session secret (ít nhất 32 ký tự): [nhập chuỗi ngẫu nhiên dài]
   ```

### Giai Đoạn 2: Cài Đặt Tự Động
Script sẽ tự động thực hiện:

1. **Cập nhật hệ thống** (5-10 phút)
2. **Cài đặt Node.js 20.x** (2-3 phút)
3. **Cài đặt PostgreSQL 14** (3-5 phút)
4. **Cài đặt Nginx** (1-2 phút)
5. **Cài đặt PM2** (1 phút)
6. **Tạo user và database** (1 phút)
7. **Deploy ứng dụng** (5-10 phút)
8. **Cấu hình SSL certificate** (2-3 phút)
9. **Thiết lập firewall** (1 phút)
10. **Cấu hình backup tự động** (1 phút)

**Tổng thời gian**: 20-35 phút

### Giai Đoạn 3: Xác Nhận Thành Công
Sau khi hoàn thành, bạn sẽ thấy:
```
============================================================================
    TRIỂN KHAI THÀNH CÔNG!
============================================================================

🎉 Hệ thống đã được triển khai thành công tại:
   Website: https://chat.yoursite.com
   Admin Panel: https://chat.yoursite.com/auth

🔐 Thông tin đăng nhập mặc định:
   Username: admin
   Password: admin123

📁 Widget Integration:
   Script: https://chat.yoursite.com/widget.js
   Style: https://chat.yoursite.com/widget.css

🛠️ Scripts quản lý:
   Kiểm tra status: sudo systemctl status chatapp
   Xem logs: pm2 logs chatapp
   Restart: pm2 restart chatapp
   Backup DB: /usr/local/bin/backup-chatapp-db.sh
```

## Xử Lý Lỗi Thường Gặp

### Lỗi Domain Chưa Trỏ Đúng
```
ERROR: Domain chưa trỏ về IP server này
```
**Giải pháp**: Kiểm tra DNS record A của domain trỏ về IP VPS

### Lỗi Quyền Sudo
```
ERROR: User không có quyền sudo
```
**Giải pháp**: 
```bash
su - root
usermod -aG sudo your-username
```

### Lỗi Port Đã Được Sử Dụng
```
ERROR: Port 80/443 đang được sử dụng
```
**Giải pháp**:
```bash
sudo systemctl stop apache2  # Nếu có Apache
sudo systemctl disable apache2
```

### Lỗi SSL Certificate
```
ERROR: Không thể tạo SSL certificate
```
**Giải pháp**: 
- Kiểm tra domain đã trỏ đúng IP
- Đợi 5-10 phút để DNS propagate
- Chạy lại: `sudo certbot --nginx -d yourdomain.com`

## Sau Khi Deploy

### Đăng Nhập Hệ Thống
1. Truy cập `https://yourdomain.com/auth`
2. Đăng nhập với `admin/admin123`
3. **Đổi mật khẩu ngay lập tức**

### Tích Hợp Widget
Thêm vào website khách hàng:
```html
<script>
window.LiveChatConfig = {
  title: 'Hỗ Trợ Khách Hàng',
  subtitle: 'Chúng tôi sẵn sàng hỗ trợ bạn',
  primaryColor: '#3b82f6',
  position: 'bottom-right'
};
</script>
<script src="https://yourdomain.com/widget.js"></script>
<link rel="stylesheet" href="https://yourdomain.com/widget.css">
```

### Scripts Quản Lý Hữu Ích
```bash
# Kiểm tra trạng thái các dịch vụ
sudo systemctl status nginx postgresql pm2-chatapp

# Xem logs ứng dụng
pm2 logs chatapp

# Restart ứng dụng
pm2 restart chatapp

# Backup database
/usr/local/bin/backup-chatapp-db.sh

# Restore database
/usr/local/bin/restore-chatapp-db.sh backup-file.sql

# Kiểm tra tình trạng SSL
sudo certbot certificates
```

### Monitoring và Bảo Trì
- **Backup tự động**: Chạy hàng ngày lúc 2:00 AM
- **Log rotation**: Tự động cleanup logs cũ
- **SSL renewal**: Tự động gia hạn SSL certificate
- **Security updates**: Kiểm tra và update định kỳ

## Liên Hệ Hỗ Trợ

Nếu gặp vấn đề trong quá trình deploy:
1. Kiểm tra logs: `sudo journalctl -u nginx -f`
2. Kiểm tra PM2: `pm2 logs`
3. Xem file log deploy: `tail -f deploy.log`

## Lưu Ý An Toàn

- **Đổi mật khẩu mặc định** ngay sau khi deploy
- **Backup thường xuyên** dữ liệu quan trọng
- **Update hệ thống** định kỳ
- **Monitor logs** để phát hiện bất thường
- **Không chia sẻ** thông tin database và session secret