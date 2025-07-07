# Hướng dẫn triển khai Real-time Chat System lên VPS Ubuntu 20.04

## Tổng quan

Script `deploy-all-in-one.sh` sẽ tự động cài đặt và cấu hình toàn bộ hệ thống chat support real-time trên VPS Ubuntu 20.04 của bạn. Sau khi chạy xong, bạn sẽ có một hệ thống hoàn chỉnh có thể tích hợp vào website để hỗ trợ khách hàng.

## Yêu cầu hệ thống

### Phần cứng tối thiểu:
- **RAM**: 2GB (khuyến nghị 4GB)
- **CPU**: 2 cores
- **Storage**: 20GB SSD
- **Bandwidth**: 100Mbps

### Phần mềm:
- **Ubuntu 20.04 LTS** (mới cài đặt)
- Quyền sudo/root để thực hiện cài đặt
- Domain name đã trỏ về IP của VPS

## Chuẩn bị trước khi triển khai

### 1. Chuẩn bị VPS
- Đảm bảo VPS đã cài Ubuntu 20.04 LTS
- Kết nối SSH thành công
- Có quyền sudo

### 2. Chuẩn bị Domain
- Mua và cấu hình domain name
- Trỏ A record của domain về IP VPS
- Kiểm tra domain đã hoạt động: `ping yourdomain.com`

### 3. Thông tin cần chuẩn bị
- Domain name (ví dụ: mychat.com)
- Email để đăng ký SSL certificate
- Mật khẩu cho database PostgreSQL (ít nhất 12 ký tự)
- Session secret (ít nhất 32 ký tự ngẫu nhiên)

## Các bước triển khai

### Bước 1: Upload source code lên VPS

```bash
# Cách 1: Sử dụng git clone (nếu có repository)
git clone https://github.com/your-repo/chat-system.git
cd chat-system

# Cách 2: Upload qua SCP
# Trên máy local:
scp -r /path/to/chat-system user@your-vps-ip:/home/user/

# Cách 3: Upload qua SFTP hoặc công cụ FTP client
```

### Bước 2: Chạy script triển khai

```bash
# Di chuyển vào thư mục source code
cd /path/to/chat-system

# Cấp quyền thực thi cho script
chmod +x deploy-all-in-one.sh

# Chạy script (KHÔNG dùng sudo)
./deploy-all-in-one.sh
```

### Bước 3: Làm theo hướng dẫn của script

Script sẽ hỏi bạn nhập các thông tin:
1. **Domain name**: Nhập domain của bạn (ví dụ: mychat.com)
2. **Email cho SSL**: Nhập email để đăng ký Let's Encrypt
3. **Database password**: Nhập mật khẩu mạnh cho PostgreSQL
4. **Session secret**: Nhập chuỗi ngẫu nhiên ít nhất 32 ký tự

### Bước 4: Chờ script hoàn thành

Script sẽ tự động:
- Cập nhật hệ thống
- Cài đặt Node.js, PostgreSQL, Nginx
- Cấu hình database
- Build và deploy ứng dụng
- Cấu hình SSL certificate
- Thiết lập firewall
- Tạo user admin mặc định

## Sau khi triển khai thành công

### Kiểm tra hệ thống

```bash
# Kiểm tra trạng thái ứng dụng
sudo /usr/local/bin/chatapp-control.sh status

# Xem logs
sudo /usr/local/bin/chatapp-control.sh logs

# Kiểm tra Nginx
sudo systemctl status nginx

# Kiểm tra PostgreSQL
sudo systemctl status postgresql
```

### Truy cập hệ thống

1. **Website chính**: https://yourdomain.com
2. **Đăng nhập admin**:
   - Username: `admin`
   - Password: `admin123`
   - **⚠️ Quan trọng**: Đổi mật khẩu ngay sau lần đăng nhập đầu tiên

### Tích hợp widget vào website

Thêm đoạn code sau vào trang web cần hỗ trợ chat:

```html
<!-- Thêm vào thẻ <head> -->
<link rel="stylesheet" href="https://yourdomain.com/widget.css">

<!-- Thêm trước thẻ đóng </body> -->
<script src="https://yourdomain.com/widget.js"></script>
<script>
  window.LiveChatConfig = {
    domain: 'yourdomain.com',
    position: 'bottom-right',  // bottom-right, bottom-left, top-right, top-left
    primaryColor: '#007bff',
    title: 'Hỗ trợ khách hàng',
    subtitle: 'Chúng tôi luôn sẵn sàng hỗ trợ bạn',
    fields: [
      { name: 'name', label: 'Họ tên', required: true },
      { name: 'email', label: 'Email', required: true },
      { name: 'phone', label: 'Số điện thoại', required: false }
    ]
  };
</script>
```

## Quản lý hệ thống

### Lệnh quản lý cơ bản

```bash
# Khởi động ứng dụng
sudo /usr/local/bin/chatapp-control.sh start

# Dừng ứng dụng
sudo /usr/local/bin/chatapp-control.sh stop

# Restart ứng dụng
sudo /usr/local/bin/chatapp-control.sh restart

# Xem trạng thái
sudo /usr/local/bin/chatapp-control.sh status

# Xem logs real-time
sudo /usr/local/bin/chatapp-control.sh logs

# Cập nhật ứng dụng (nếu có code mới)
sudo /usr/local/bin/chatapp-control.sh update
```

### Backup database

```bash
# Backup thủ công
sudo /usr/local/bin/backup-chatapp-db.sh

# Xem các file backup
ls -la /home/chatapp/backups/

# Restore từ backup
sudo -u postgres psql chatapp_db < /home/chatapp/backups/backup_file.sql
```

### Quản lý SSL certificate

```bash
# Kiểm tra trạng thái SSL
sudo certbot certificates

# Gia hạn SSL (tự động)
sudo certbot renew

# Test gia hạn
sudo certbot renew --dry-run
```

## Cấu hình nâng cao

### Thay đổi port ứng dụng

1. Sửa file `/home/chatapp/chat-system/ecosystem.config.js`
2. Thay đổi `PORT: 3000` thành port mong muốn
3. Cập nhật cấu hình Nginx trong `/etc/nginx/sites-available/chatapp`
4. Restart dịch vụ:
   ```bash
   sudo /usr/local/bin/chatapp-control.sh restart
   sudo systemctl reload nginx
   ```

### Thêm agent mới

1. Truy cập admin panel: https://yourdomain.com
2. Đăng nhập với tài khoản admin
3. Vào mục "Quản lý Users" → "Thêm Agent mới"
4. Điền thông tin và phân quyền

### Cấu hình email notifications (tùy chọn)

Để bật thông báo email, cần cấu hình SMTP:

1. Sửa file `.env`:
   ```bash
   sudo nano /home/chatapp/chat-system/.env
   ```

2. Thêm cấu hình SMTP:
   ```
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASS=your-app-password
   ```

3. Restart ứng dụng:
   ```bash
   sudo /usr/local/bin/chatapp-control.sh restart
   ```

## Troubleshooting

### Ứng dụng không khởi động

```bash
# Kiểm tra logs
sudo /usr/local/bin/chatapp-control.sh logs

# Kiểm tra cấu hình database
sudo -u chatapp psql -h localhost -U chatapp_user -d chatapp_db -c "\dt"

# Kiểm tra port có bị chiếm
sudo netstat -tulpn | grep :3000
```

### Website không truy cập được

```bash
# Kiểm tra Nginx
sudo nginx -t
sudo systemctl status nginx

# Kiểm tra SSL
sudo certbot certificates

# Kiểm tra firewall
sudo ufw status
```

### Widget không hiển thị

1. Kiểm tra console browser có lỗi không
2. Kiểm tra CORS headers:
   ```bash
   curl -H "Origin: https://your-website.com" -I https://yourdomain.com/widget.js
   ```

### Performance tuning

```bash
# Tăng worker processes cho Nginx
sudo nano /etc/nginx/nginx.conf
# Sửa: worker_processes auto;

# Tăng PM2 instances
sudo nano /home/chatapp/chat-system/ecosystem.config.js
# Sửa: instances: 'max'

# Restart services
sudo systemctl reload nginx
sudo /usr/local/bin/chatapp-control.sh restart
```

## Bảo mật

### Cập nhật định kỳ

```bash
# Cập nhật hệ thống
sudo apt update && sudo apt upgrade -y

# Cập nhật Node.js dependencies
cd /home/chatapp/chat-system
sudo -u chatapp npm audit fix

# Restart ứng dụng
sudo /usr/local/bin/chatapp-control.sh restart
```

### Thay đổi mật khẩu admin

1. Đăng nhập admin panel
2. Vào "Profile" → "Đổi mật khẩu"
3. Nhập mật khẩu mới (ít nhất 12 ký tự, có chữ hoa, số, ký tự đặc biệt)

### Cấu hình backup tự động

Backup đã được cấu hình chạy hàng ngày lúc 2:00 AM. Để thay đổi:

```bash
# Chỉnh sửa crontab
crontab -e

# Thay đổi thời gian backup (ví dụ: 3:30 AM)
# 30 3 * * * /usr/local/bin/backup-chatapp-db.sh
```

## Liên hệ hỗ trợ

Nếu gặp vấn đề trong quá trình triển khai hoặc sử dụng, vui lòng:

1. Kiểm tra logs chi tiết
2. Tham khảo phần Troubleshooting
3. Đọc tài liệu kỹ thuật trong `/home/chatapp/chat-system/`

---

**Lưu ý**: Document này cung cấp hướng dẫn cơ bản cho việc triển khai và quản lý hệ thống. Đối với các yêu cầu đặc biệt hoặc tùy chỉnh nâng cao, cần có kiến thức kỹ thuật về Node.js, PostgreSQL và Linux.