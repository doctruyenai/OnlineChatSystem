# DANH SACH FILES TRIEN KHAI

## ✅ FILES CHINH CHO DEPLOYMENT

### 🚀 Scripts Deploy
| File | Mo ta | Su dung |
|------|-------|---------|
| `deploy-from-github-fixed.sh` | **Deploy tu GitHub (FIXED)** | `./deploy-from-github-fixed.sh` |
| `deploy-all-in-one.sh` | Script deploy chinh | `./deploy-all-in-one.sh` |
| `deploy-from-github.sh` | Deploy tu GitHub (cu) | `./deploy-from-github.sh` |

### 📋 Scripts Kiem Tra
| File | Mo ta | Su dung |
|------|-------|---------|
| `check-requirements.sh` | Kiem tra VPS requirements | `./check-requirements.sh` |
| `check-deploy-files.sh` | Kiem tra files day du | `./check-deploy-files.sh` |

### ⚙️ Cau Hinh
| File | Mo ta | Su dung |
|------|-------|---------|
| `deployment.config.sh` | Cau hinh deployment | `nano deployment.config.sh` |
| `ecosystem.config.js` | Cau hinh PM2 | Automatic |

### 📚 Huong Dan
| File | Mo ta |
|------|-------|
| `HUONG_DAN_DEPLOY_TU_GITHUB.md` | Huong dan deploy tu GitHub |
| `HUONG_DAN_SU_DUNG_DEPLOY.md` | Huong dan chi tiet |
| `SUMMARY_DEPLOYMENT.md` | Tom tat toan bo |
| `quick-start-github.sh` | Huong dan nhanh |

### 🔧 Support Scripts
| File | Mo ta |
|------|-------|
| `convert-vietnamese-no-diacritics.sh` | Chuyen doi tieng Viet khong dau |
| `setup-deployment.sh` | Setup ban dau |

## 🌟 KHUYẾN NGHỊ SỬ DỤNG

### Deploy Nhanh Nhất (1 Lệnh)
```bash
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github-fixed.sh | bash
```

### Deploy Từ Local
```bash
# Buoc 1: Kiem tra
./check-requirements.sh

# Buoc 2: Deploy
./deploy-all-in-one.sh
```

## 📁 CẤU TRÚC THƯ MỤC SAU DEPLOY

```
/home/chatapp/chat-system/
├── server/           # Backend code
├── client/           # Frontend code  
├── shared/           # Shared types
├── public/           # Static files + widget
├── .env             # Environment variables
├── package.json     # Dependencies
├── ecosystem.config.js  # PM2 config
└── logs/            # Application logs
```

## 🔍 KIỂM TRA DEPLOYMENT

### Kiem Tra Services
```bash
# Kiem tra PM2
pm2 status

# Kiem tra Nginx
sudo systemctl status nginx

# Kiem tra PostgreSQL
sudo systemctl status postgresql
```

### Kiem Tra Website
- Website: https://yourdomain.com
- Admin: https://yourdomain.com/auth
- Widget demo: https://yourdomain.com/widget-demo

## 🔄 UPDATE HỆ THỐNG

```bash
# Cap nhat tu GitHub
sudo /usr/local/bin/chatapp-control.sh update

# Backup database
sudo /usr/local/bin/backup-chatapp-db.sh
```

## 📞 HỖ TRỢ

Neu gap van de trong qua trinh deploy:

1. **Kiem tra logs**: `pm2 logs`
2. **Kiem tra requirements**: `./check-requirements.sh`  
3. **Kiem tra files**: `./check-deploy-files.sh`
4. **Restart services**: `sudo /usr/local/bin/chatapp-control.sh restart`

## 🎯 GHI CHÚ QUAN TRỌNG

- ⚠️ **Doi mat khau admin** ngay sau khi deploy: `admin/admin123`
- 🔒 **Backup database** thuong xuyen
- 🔄 **Update he thong** dinh ky tu GitHub
- 📧 **Email SSL** phai hop le de lay certificate
- 🌐 **Domain** phai tro ve IP VPS truoc khi deploy