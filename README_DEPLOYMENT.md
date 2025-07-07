# Script Triển Khai All-in-One cho Real-time Chat System

## Tổng quan nhanh

Script `deploy-all-in-one.sh` sẽ tự động cài đặt toàn bộ hệ thống chat support trên VPS Ubuntu 20.04 của bạn. Chỉ cần chạy 1 lệnh và có ngay hệ thống hoàn chỉnh!

## Cài đặt nhanh (5 phút)

### Bước 1: Chuẩn bị
- VPS Ubuntu 20.04 với quyền sudo
- Domain name đã trỏ về IP VPS
- Email để đăng ký SSL certificate

### Bước 2: Upload source code
```bash
# Upload toàn bộ thư mục source code lên VPS
scp -r /path/to/chat-system user@your-vps-ip:/home/user/
```

### Bước 3: Chạy script
```bash
cd /path/to/chat-system
chmod +x deploy-all-in-one.sh
./deploy-all-in-one.sh
```

### Bước 4: Nhập thông tin khi được hỏi
- Domain name (ví dụ: mychat.com)
- Email cho SSL certificate
- Mật khẩu database PostgreSQL (mạnh, ít nhất 12 ký tự)
- Session secret (ngẫu nhiên, ít nhất 32 ký tự)

### Bước 5: Chờ hoàn thành (10-15 phút)
Script sẽ tự động cài đặt tất cả và báo thành công.

## Sau khi cài đặt xong

### Truy cập hệ thống
- **Website**: https://yourdomain.com
- **Admin**: Đăng nhập với `admin` / `admin123`
- **Widget**: https://yourdomain.com/widget.js

### Tích hợp vào website
Thêm vào website cần chat support:
```html
<link rel="stylesheet" href="https://yourdomain.com/widget.css">
<script src="https://yourdomain.com/widget.js"></script>
<script>
  window.LiveChatConfig = {
    domain: 'yourdomain.com',
    position: 'bottom-right',
    primaryColor: '#007bff',
    title: 'Hỗ trợ khách hàng'
  };
</script>
```

### Quản lý hệ thống
```bash
# Xem trạng thái
sudo /usr/local/bin/chatapp-control.sh status

# Restart
sudo /usr/local/bin/chatapp-control.sh restart

# Xem logs
sudo /usr/local/bin/chatapp-control.sh logs
```

## Tính năng chính

✅ **Hoàn toàn tự động**: Chỉ cần chạy 1 lệnh
✅ **Real-time chat**: WebSocket cho chat tức thời
✅ **Admin dashboard**: Quản lý conversations và agents
✅ **Embeddable widget**: Tích hợp dễ dàng vào mọi website
✅ **SSL tự động**: HTTPS với Let's Encrypt
✅ **Backup tự động**: Database backup hàng ngày
✅ **Production ready**: PM2, Nginx, PostgreSQL

## Hỗ trợ

- Đọc chi tiết: `HUONG_DAN_TRIEN_KHAI.md`
- Xem logs nếu có lỗi: `sudo /usr/local/bin/chatapp-control.sh logs`
- Kiểm tra dịch vụ: `sudo /usr/local/bin/chatapp-control.sh status`

---

**Quan trọng**: Đổi mật khẩu admin sau lần đăng nhập đầu tiên!