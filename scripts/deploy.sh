#!/bin/bash
set -e

cd ../terraform

echo "[1/3] Initializing terraform..."
terraform init

echo "[2/3] Validating terraform..."
terraform validate

echo "[3/3] Deploying infrastructure..."
terraform apply -auto-approve

echo "[DONE] Deployment completed!"
