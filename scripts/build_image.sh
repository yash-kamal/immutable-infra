#!/bin/bash
set -e

echo "[1/3] Validating Packer template..."
packer validate ../packer/ubuntu.json

echo "[2/3] Building the image..."
packer build ../packer/ubuntu.json

echo "[3/3] Exporting AMI ID..."
AMI_ID=$(aws ec2 describe-images \
    --owners self \
    --query 'Images[*].ImageId' \
    --output text | head -n 1)

echo "AMI_ID=$AMI_ID" > ../terraform/ami.auto.tfvars

echo "[DONE] Image created successfully → $AMI_ID"
