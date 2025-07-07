#!/bin/bash

# ==============================================================================
# FILE CẤU HÌNH TRIỂN KHAI - REAL-TIME CHAT SYSTEM
# Tùy chỉnh các thông số trước khi triển khai
# ==============================================================================

# Thông tin cơ bản
export APP_NAME="chatapp"
export APP_USER="chatapp"
export DB_NAME="chatapp_db"
export DB_USER="chatapp_user"

# Cấu hình Node.js
export NODE_VERSION="20.x"
export PM2_INSTANCES="max"          # Số instances PM2 (max = số CPU cores)
export APP_PORT="3000"              # Port ứng dụng
export NODE_ENV="production"

# Cấu hình PostgreSQL
export POSTGRES_VERSION="14"       # Phiên bản PostgreSQL
export POSTGRES_MAX_CONNECTIONS="100"
export POSTGRES_SHARED_BUFFERS="256MB"
export POSTGRES_EFFECTIVE_CACHE_SIZE="1GB"

# Cấu hình Nginx
export NGINX_WORKER_PROCESSES="auto"
export NGINX_WORKER_CONNECTIONS="1024"
export NGINX_CLIENT_MAX_BODY_SIZE="10M"
export NGINX_KEEPALIVE_TIMEOUT="65"

# Cấu hình SSL
export SSL_PROVIDER="letsencrypt"   # letsencrypt hoặc custom
export SSL_EMAIL=""                 # Sẽ được hỏi trong quá trình cài đặt
export SSL_KEY_SIZE="4096"

# Cấu hình Backup
export BACKUP_RETENTION_DAYS="7"   # Số ngày giữ backup
export BACKUP_TIME="2"              # Giờ chạy backup (0-23)
export BACKUP_MINUTE="0"            # Phút chạy backup (0-59)

# Cấu hình Security
export UFW_ENABLE="true"            # Bật firewall
export SSH_PORT="22"                # Port SSH (mặc định 22)
export FAIL2BAN_ENABLE="true"       # Bật fail2ban

# Cấu hình Performance
export ENABLE_GZIP="true"           # Bật gzip compression
export ENABLE_CACHE="true"          # Bật browser caching
export MAX_UPLOAD_SIZE="10M"        # Kích thước file upload tối đa

# Cấu hình Monitoring
export ENABLE_LOG_ROTATION="true"   # Bật log rotation
export LOG_MAX_SIZE="100M"          # Kích thước log tối đa
export LOG_RETENTION_DAYS="30"      # Số ngày giữ log

# Cấu hình Widget
export WIDGET_DEFAULT_POSITION="bottom-right"
export WIDGET_DEFAULT_COLOR="#007bff"
export WIDGET_DEFAULT_TITLE="Hỗ trợ khách hàng"

# Cấu hình SMTP (tùy chọn)
export SMTP_ENABLE="false"          # Bật SMTP
export SMTP_HOST=""                 # SMTP server
export SMTP_PORT="587"              # SMTP port
export SMTP_SECURE="false"          # Sử dụng SSL/TLS
export SMTP_USER=""                 # SMTP username
export SMTP_PASS=""                 # SMTP password

# Cấu hình Redis (tùy chọn - cho session store)
export REDIS_ENABLE="false"         # Bật Redis
export REDIS_HOST="127.0.0.1"
export REDIS_PORT="6379"
export REDIS_PASSWORD=""

# Cấu hình Debug
export DEBUG_MODE="false"           # Bật debug mode
export VERBOSE_LOGGING="false"      # Bật verbose logging

# Advanced Settings (chỉ chỉnh nếu hiểu rõ)
export NODEJS_MAX_OLD_SPACE_SIZE="2048"  # MB
export POSTGRES_WORK_MEM="4MB"
export POSTGRES_MAINTENANCE_WORK_MEM="64MB"

# Hàm hiển thị cấu hình hiện tại
show_config() {
    echo "==================== CẤU HÌNH TRIỂN KHAI ===================="
    echo "App Name: $APP_NAME"
    echo "App User: $APP_USER"
    echo "App Port: $APP_PORT"
    echo "Database: $DB_NAME"
    echo "Node.js: $NODE_VERSION"
    echo "PM2 Instances: $PM2_INSTANCES"
    echo "PostgreSQL: Version $POSTGRES_VERSION"
    echo "SSL Provider: $SSL_PROVIDER"
    echo "Backup Retention: $BACKUP_RETENTION_DAYS days"
    echo "Firewall: $UFW_ENABLE"
    echo "SMTP: $SMTP_ENABLE"
    echo "Redis: $REDIS_ENABLE"
    echo "Debug Mode: $DEBUG_MODE"
    echo "=========================================================="
}

# Hàm validate cấu hình
validate_config() {
    local errors=0
    
    # Kiểm tra port
    if ! [[ "$APP_PORT" =~ ^[0-9]+$ ]] || [ "$APP_PORT" -lt 1000 ] || [ "$APP_PORT" -gt 65535 ]; then
        echo "ERROR: APP_PORT phải là số từ 1000-65535"
        ((errors++))
    fi
    
    # Kiểm tra backup retention
    if ! [[ "$BACKUP_RETENTION_DAYS" =~ ^[0-9]+$ ]] || [ "$BACKUP_RETENTION_DAYS" -lt 1 ]; then
        echo "ERROR: BACKUP_RETENTION_DAYS phải là số dương"
        ((errors++))
    fi
    
    # Kiểm tra backup time
    if ! [[ "$BACKUP_TIME" =~ ^[0-9]+$ ]] || [ "$BACKUP_TIME" -lt 0 ] || [ "$BACKUP_TIME" -gt 23 ]; then
        echo "ERROR: BACKUP_TIME phải là số từ 0-23"
        ((errors++))
    fi
    
    return $errors
}

# Nếu script được chạy trực tiếp
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        show)
            show_config
            ;;
        validate)
            if validate_config; then
                echo "✓ Cấu hình hợp lệ"
                exit 0
            else
                echo "✗ Cấu hình có lỗi"
                exit 1
            fi
            ;;
        *)
            echo "Sử dụng:"
            echo "  source deployment.config.sh  # Load cấu hình"
            echo "  ./deployment.config.sh show  # Hiển thị cấu hình"
            echo "  ./deployment.config.sh validate  # Kiểm tra cấu hình"
            ;;
    esac
fi