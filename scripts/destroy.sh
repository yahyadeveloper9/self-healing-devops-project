#!/bin/bash
set -e

echo "============================================================"
echo "DESTROYING SELF-HEALING RESUME PLATFORM"
echo "============================================================"

read -p "Type DESTROY to continue: " CONFIRM

if [ "$CONFIRM" != "DESTROY" ]; then
    echo "Destruction cancelled."
    exit 0
fi

echo "Running terraform destroy..."
cd terraform
terraform destroy -auto-approve

echo "============================================================"
echo "DESTRUCTION COMPLETE"
echo "============================================================"
