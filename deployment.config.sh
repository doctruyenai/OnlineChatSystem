#!/bin/bash

# ==============================================================================
# FILE CAU HINH TRIEN KHAI - REAL-TIME CHAT SYSTEM
# Tuy chinh cac thong so truoc khi trien khai
# ==============================================================================

# Thong tin co ban
export APP_NAME="chatapp"
export APP_USER="chatapp"
export DB_NAME="chatapp_db"
export DB_USER="chatapp_user"

# Cau hinh Node.js
export NODE_VERSION="20.x"
export PM2_INSTANCES="max"          # So instances PM2 (max = so CPU cores)
export APP_PORT="3000"              # Port ung dung
export NODE_ENV="production"

# Cau hinh PostgreSQL
export POSTGRES_VERSION="14"       # Phien ban PostgreSQL
export POSTGRES_MAX_CONNECTIONS="100"
export POSTGRES_SHARED_BUFFERS="256MB"
export POSTGRES_EFFECTIVE_CACHE_SIZE="1GB"

# Cau hinh Nginx
export NGINX_WORKER_PROCESSES="auto"
export NGINX_WORKER_CONNECTIONS="1024"
export NGINX_CLIENT_MAX_BODY_SIZE="10M"
export NGINX_KEEPALIVE_TIMEOUT="65"

# Cau hinh SSL
export SSL_PROVIDER="letsencrypt"   # letsencrypt hoac custom
export SSL_EMAIL=""                 # Se duoc hoi trong qua trinh cai dat
export SSL_KEY_SIZE="4096"

# Cau hinh Backup
export BACKUP_RETENTION_DAYS="7"   # So ngay giu backup
export BACKUP_TIME="2"              # Gio chay backup (0-23)
export BACKUP_MINUTE="0"            # Phut chay backup (0-59)

# Cau hinh Security
export UFW_ENABLE="true"            # Bat firewall
export SSH_PORT="22"                # Port SSH (mac dinh 22)
export FAIL2BAN_ENABLE="true"       # Bat fail2ban

# Cau hinh Performance
export ENABLE_GZIP="true"           # Bat gzip compression
export ENABLE_CACHE="true"          # Bat browser caching
export MAX_UPLOAD_SIZE="10M"        # Kich thuoc file upload toi da

# Cau hinh Monitoring
export ENABLE_LOG_ROTATION="true"   # Bat log rotation
export LOG_MAX_SIZE="100M"          # Kich thuoc log toi da
export LOG_RETENTION_DAYS="30"      # So ngay giu log

# Cau hinh Widget
export WIDGET_DEFAULT_POSITION="bottom-right"
export WIDGET_DEFAULT_COLOR="#007bff"
export WIDGET_DEFAULT_TITLE="Ho tro khach hang"

# Cau hinh SMTP (tuy chon)
export SMTP_ENABLE="false"          # Bat SMTP
export SMTP_HOST=""                 # SMTP server
export SMTP_PORT="587"              # SMTP port
export SMTP_SECURE="false"          # Su dung SSL/TLS
export SMTP_USER=""                 # SMTP username
export SMTP_PASS=""                 # SMTP password

# Cau hinh Redis (tuy chon - cho session store)
export REDIS_ENABLE="false"         # Bat Redis
export REDIS_HOST="127.0.0.1"
export REDIS_PORT="6379"
export REDIS_PASSWORD=""

# Cau hinh Debug
export DEBUG_MODE="false"           # Bat debug mode
export VERBOSE_LOGGING="false"      # Bat verbose logging

# Advanced Settings (chi chinh neu hieu ro)
export NODEJS_MAX_OLD_SPACE_SIZE="2048"  # MB
export POSTGRES_WORK_MEM="4MB"
export POSTGRES_MAINTENANCE_WORK_MEM="64MB"

# Ham hien thi cau hinh hien tai
show_config() {
    echo "==================== CAU HINH TRIEN KHAI ===================="
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

# Ham validate cau hinh
validate_config() {
    local errors=0
    
    # Kiem tra port
    if ! [[ "$APP_PORT" =~ ^[0-9]+$ ]] || [ "$APP_PORT" -lt 1000 ] || [ "$APP_PORT" -gt 65535 ]; then
        echo "ERROR: APP_PORT phai la so tu 1000-65535"
        ((errors++))
    fi
    
    # Kiem tra backup retention
    if ! [[ "$BACKUP_RETENTION_DAYS" =~ ^[0-9]+$ ]] || [ "$BACKUP_RETENTION_DAYS" -lt 1 ]; then
        echo "ERROR: BACKUP_RETENTION_DAYS phai la so duong"
        ((errors++))
    fi
    
    # Kiem tra backup time
    if ! [[ "$BACKUP_TIME" =~ ^[0-9]+$ ]] || [ "$BACKUP_TIME" -lt 0 ] || [ "$BACKUP_TIME" -gt 23 ]; then
        echo "ERROR: BACKUP_TIME phai la so tu 0-23"
        ((errors++))
    fi
    
    return $errors
}

# Neu script duoc chay truc tiep
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        show)
            show_config
            ;;
        validate)
            if validate_config; then
                echo "✓ Cau hinh hop le"
                exit 0
            else
                echo "✗ Cau hinh co loi"
                exit 1
            fi
            ;;
        *)
            echo "Su dung:"
            echo "  source deployment.config.sh  # Load cau hinh"
            echo "  ./deployment.config.sh show  # Hien thi cau hinh"
            echo "  ./deployment.config.sh validate  # Kiem tra cau hinh"
            ;;
    esac
fi