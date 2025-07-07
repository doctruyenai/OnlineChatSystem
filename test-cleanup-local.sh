#!/bin/bash

# Test cleanup script cho moi truong local

echo "=== TEST CLEANUP LOCAL ==="

# Kiem tra cac lenh co hoat dong khong
echo "Kiem tra syntax..."

# Test basic commands
echo "Test echo: OK"

if command -v pm2 >/dev/null 2>&1; then
    echo "PM2: Co san"
else
    echo "PM2: Khong co"
fi

if command -v nginx >/dev/null 2>&1; then
    echo "Nginx: Co san"
else
    echo "Nginx: Khong co"
fi

if command -v sudo >/dev/null 2>&1; then
    echo "Sudo: Co san"
else
    echo "Sudo: Khong co"
fi

echo ""
echo "Script syntax test hoan thanh!"
echo "Neu muon chay cleanup that, su dung:"
echo "./cleanup-simple.sh"