#!/bin/bash

# ==============================================================================
# FULL CLEAN DEPLOY - DON DEP VA CAI DAT MOI HOAN TOAN
# Script ket hop don dep va cai dat moi trong 1 lenh
# ==============================================================================

set -e

# Mau sac
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "============================================================================"
echo "              DON DEP VA CAI DAT MOI HOAN TOAN"
echo "============================================================================"
echo -e "${NC}"

echo -e "${YELLOW}Script nay se:${NC}"
echo "1. Xoa toan bo cai dat cu (neu co)"
echo "2. Tai code moi tu GitHub"
echo "3. Cai dat he thong moi hoan toan"
echo ""

read -p "Ban co muon tiep tuc? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Huy bo."
    exit 1
fi

# Buoc 1: Xoa cai dat cu
echo -e "\n${BLUE}==================== BUOC 1: XOA CAI DAT CU ====================${NC}"

# Tai va chay script cleanup
if [[ -f "cleanup-old-installation.sh" ]]; then
    echo "Su dung script cleanup local..."
    ./cleanup-old-installation.sh
else
    echo "Tai script cleanup tu GitHub..."
    curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/cleanup-old-installation.sh | bash
fi

# Buoc 2: Cai dat moi
echo -e "\n${BLUE}==================== BUOC 2: CAI DAT MOI ====================${NC}"

# Tai va chay script deploy moi
curl -sSL https://raw.githubusercontent.com/doctruyenai/OnlineChatSystem/main/deploy-from-github-fixed.sh | bash

echo -e "\n${GREEN}============================================================================"
echo "                    DON DEP VA CAI DAT MOI HOAN THANH!"
echo "============================================================================${NC}"