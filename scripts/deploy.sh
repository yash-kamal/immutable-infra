#!/usr/bin/env bash
set -euo pipefail

STRATEGY="${DEPLOYMENT_STRATEGY:-blue-green}"
VERSION="${1:-}"   # optional first arg (e.g. new AMI tag or image version)
TF_WORKDIR="${TF_WORKDIR:-terraform}"

echo "Deployment strategy: $STRATEGY"
echo "Version: $VERSION"

case "$STRATEGY" in
  blue-green)
    ./scripts/blue_green.sh "$VERSION"
    ;;
  canary)
    ./scripts/canary.sh "$VERSION"
    ;;
  rolling)
    ./scripts/rolling.sh "$VERSION"
    ;;
  *)
    echo "Unknown deployment strategy: $STRATEGY"
    exit 2
    ;;
esac

set -e

cd ../terraform

echo "[1/3] Initializing terraform..."
terraform init

echo "[2/3] Validating terraform..."
terraform validate

echo "[3/3] Deploying infrastructure..."
terraform apply -auto-approve

echo "[DONE] Deployment completed!"
