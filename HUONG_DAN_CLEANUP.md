# HUONG DAN XOA CAI DAT CU

## 🧹 3 SCRIPT XOA CAI DAT CU

### 1. cleanup-old-installation.sh - XOA HOAN TOAN
**Muc dich:** Xoa toan bo cai dat cu mot cach chi tiet va an toan

```bash
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/cleanup-old-installation.sh | bash
```

**Xoa:** 
- ✓ PM2 processes va configuration
- ✓ Nginx sites config
- ✓ SSL certificates
- ✓ PostgreSQL databases va users
- ✓ System user (chatapp)
- ✓ Application files (/home/chatapp, /var/www/chat-system, etc.)
- ✓ System scripts (/usr/local/bin/chatapp-*)
- ✓ Systemd services
- ✓ Cron jobs
- ✓ Log files
- ✓ Backup files
- ✓ Firewall rules
- ✓ Cache va temp files

### 2. full-clean-deploy.sh - DON DEP + CAI DAT MOI
**Muc dich:** Xoa sach va cai dat moi trong 1 lenh

```bash
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/full-clean-deploy.sh | bash
```

**Thuc hien:**
1. Goi script cleanup-old-installation.sh
2. Goi script deploy-from-github-fixed.sh
3. Ket qua: He thong moi hoan toan

### 3. emergency-cleanup.sh - XOA KHAU CAP
**Muc dich:** Xoa nhanh khi gap van de

```bash
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/emergency-cleanup.sh | bash
```

**Xoa nhanh:**
- ✓ Kill processes
- ✓ Xoa PM2
- ✓ Stop services
- ✓ Xoa files quan trong
- ✓ Xoa database
- ✓ Xoa user
- ✓ Khoi phuc Nginx

## 📋 TINH HUONG SU DUNG

### Khi Muon Cai Dat Moi Tu Dau
```bash
# Phuong phap 1: Xoa roi cai dat
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/cleanup-old-installation.sh | bash
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github-fixed.sh | bash

# Phuong phap 2: Lam ca 2 trong 1 lenh
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/full-clean-deploy.sh | bash
```

### Khi Deploy Bi Loi
```bash
# Xoa sach va thu lai
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/cleanup-old-installation.sh | bash
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github-fixed.sh | bash
```

### Khi Gap Van De Khau Cap
```bash
# Xoa nhanh
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/emergency-cleanup.sh | bash
```

### Khi Muon Chuyen Doi System
```bash
# Backup truoc (neu can)
sudo /usr/local/bin/backup-chatapp-db.sh

# Xoa he thong cu
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/cleanup-old-installation.sh | bash

# Cai dat he thong moi
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github-fixed.sh | bash
```

## 🛡️ AN TOAN

### Truoc Khi Cleanup
1. **Backup database** neu can giu du lieu
2. **Luu cau hinh** quan trong
3. **Kiem tra** cac service khac tren server

### Sau Khi Cleanup
1. **Kiem tra** cac service khac con hoat dong
2. **Khoi phuc** Nginx default neu can
3. **Kiem tra** firewall rules

## 🔍 KIEM TRA KET QUA

### Sau khi chay cleanup:
```bash
# Kiem tra PM2
pm2 status      # Khong con process nao

# Kiem tra Nginx
sudo systemctl status nginx    # Dang chay binh thuong

# Kiem tra Database
sudo -u postgres psql -c "\l"  # Khong con database chatapp

# Kiem tra User
id chatapp      # User khong ton tai

# Kiem tra Files
ls /home/chatapp        # Thu muc khong ton tai
ls /var/www/chat*       # Khong co file nao
```

## 📞 HO TRO

Neu cleanup khong thanh cong:

1. **Chay emergency cleanup**:
   ```bash
   curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/emergency-cleanup.sh | bash
   ```

2. **Kiem tra processes con lai**:
   ```bash
   ps aux | grep -E "(chat|pm2|nginx)" | grep -v grep
   ```

3. **Xoa thu cong** neu can:
   ```bash
   sudo pkill -f "chat\|pm2"
   sudo rm -rf /home/chatapp /var/www/chat* /opt/chat*
   ```

## 🎯 LUU Y QUAN TRONG

- Scripts yeu cau quyen **sudo**
- **Backup** du lieu quan trong truoc khi cleanup
- **Doc ky** cac buoc truoc khi dong y
- **Kiem tra** server con cac service khac
- **Khoi phuc** Nginx default sau cleanup

---

**Cleanup nhanh nhat:**
```bash
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/full-clean-deploy.sh | bash
```