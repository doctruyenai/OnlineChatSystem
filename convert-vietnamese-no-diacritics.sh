#!/bin/bash

# Script chuyen doi tieng Viet co dau thanh khong dau
# Tranh loi hien thi khi deploy

FILES_TO_CONVERT=(
    "deploy-all-in-one.sh"
    "deploy-from-github.sh"
    "HUONG_DAN_SU_DUNG_DEPLOY.md"
    "HUONG_DAN_DEPLOY_TU_GITHUB.md"
    "SUMMARY_DEPLOYMENT.md"
    "quick-deploy-guide.sh"
    "quick-start-github.sh"
    "check-requirements.sh"
    "deployment.config.sh"
)

# Function chuyen doi
convert_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "File $file khong ton tai"
        return
    fi
    
    echo "Chuyen doi file: $file"
    
    # Backup original file
    cp "$file" "$file.backup"
    
    # Convert Vietnamese characters
    sed -i 's/à/a/g; s/á/a/g; s/ạ/a/g; s/ả/a/g; s/ã/a/g' "$file"
    sed -i 's/â/a/g; s/ầ/a/g; s/ấ/a/g; s/ậ/a/g; s/ẩ/a/g; s/ẫ/a/g' "$file"
    sed -i 's/ă/a/g; s/ằ/a/g; s/ắ/a/g; s/ặ/a/g; s/ẳ/a/g; s/ẵ/a/g' "$file"
    sed -i 's/è/e/g; s/é/e/g; s/ẹ/e/g; s/ẻ/e/g; s/ẽ/e/g' "$file"
    sed -i 's/ê/e/g; s/ề/e/g; s/ế/e/g; s/ệ/e/g; s/ể/e/g; s/ễ/e/g' "$file"
    sed -i 's/ì/i/g; s/í/i/g; s/ị/i/g; s/ỉ/i/g; s/ĩ/i/g' "$file"
    sed -i 's/ò/o/g; s/ó/o/g; s/ọ/o/g; s/ỏ/o/g; s/õ/o/g' "$file"
    sed -i 's/ô/o/g; s/ồ/o/g; s/ố/o/g; s/ộ/o/g; s/ổ/o/g; s/ỗ/o/g' "$file"
    sed -i 's/ơ/o/g; s/ờ/o/g; s/ớ/o/g; s/ợ/o/g; s/ở/o/g; s/ỡ/o/g' "$file"
    sed -i 's/ù/u/g; s/ú/u/g; s/ụ/u/g; s/ủ/u/g; s/ũ/u/g' "$file"
    sed -i 's/ư/u/g; s/ừ/u/g; s/ứ/u/g; s/ự/u/g; s/ử/u/g; s/ữ/u/g' "$file"
    sed -i 's/ỳ/y/g; s/ý/y/g; s/ỵ/y/g; s/ỷ/y/g; s/ỹ/y/g' "$file"
    sed -i 's/đ/d/g; s/Đ/D/g' "$file"
    
    # Uppercase versions
    sed -i 's/À/A/g; s/Á/A/g; s/Ạ/A/g; s/Ả/A/g; s/Ã/A/g' "$file"
    sed -i 's/Â/A/g; s/Ầ/A/g; s/Ấ/A/g; s/Ậ/A/g; s/Ẩ/A/g; s/Ẫ/A/g' "$file"
    sed -i 's/Ă/A/g; s/Ằ/A/g; s/Ắ/A/g; s/Ặ/A/g; s/Ẳ/A/g; s/Ẵ/A/g' "$file"
    sed -i 's/È/E/g; s/É/E/g; s/Ẹ/E/g; s/Ẻ/E/g; s/Ẽ/E/g' "$file"
    sed -i 's/Ê/E/g; s/Ề/E/g; s/Ế/E/g; s/Ệ/E/g; s/Ể/E/g; s/Ễ/E/g' "$file"
    sed -i 's/Ì/I/g; s/Í/I/g; s/Ị/I/g; s/Ỉ/I/g; s/Ĩ/I/g' "$file"
    sed -i 's/Ò/O/g; s/Ó/O/g; s/Ọ/O/g; s/Ỏ/O/g; s/Õ/O/g' "$file"
    sed -i 's/Ô/O/g; s/Ồ/O/g; s/Ố/O/g; s/Ộ/O/g; s/Ổ/O/g; s/Ỗ/O/g' "$file"
    sed -i 's/Ơ/O/g; s/Ờ/O/g; s/Ớ/O/g; s/Ợ/O/g; s/Ở/O/g; s/Ỡ/O/g' "$file"
    sed -i 's/Ù/U/g; s/Ú/U/g; s/Ụ/U/g; s/Ủ/U/g; s/Ũ/U/g' "$file"
    sed -i 's/Ư/U/g; s/Ừ/U/g; s/Ứ/U/g; s/Ự/U/g; s/Ử/U/g; s/Ữ/U/g' "$file"
    sed -i 's/Ỳ/Y/g; s/Ý/Y/g; s/Ỵ/Y/g; s/Ỷ/Y/g; s/Ỹ/Y/g' "$file"
    
    echo "Da chuyen doi xong: $file"
}

echo "Bat dau chuyen doi cac file deploy..."

for file in "${FILES_TO_CONVERT[@]}"; do
    convert_file "$file"
done

echo "Hoan thanh chuyen doi tat ca files!"
echo "Cac file backup co duoi .backup neu can restore"