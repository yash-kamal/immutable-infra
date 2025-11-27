#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-$(date +%s)}"   # fallback version identifier
TF_DIR="${TF_DIR:-../terraform}"  # relative path from scripts/, adapt if needed
HEALTH_URL="${HEALTH_URL:-http://<green-instance-ip-or-dns>/health}"  # placeholder — script will update with actual ip

WORKSPACE="green-${VERSION}"

echo "Starting blue/green deployment: workspace=$WORKSPACE"

pushd "$TF_DIR" > /dev/null

terraform workspace new "$WORKSPACE" || terraform workspace select "$WORKSPACE"

terraform init -input=false
terraform apply -auto-approve -var="app_image_tag=${VERSION}"

LISTENER_ARN=$(terraform output -raw alb_listener_arn)
NEW_TG_ARN=$(terraform output -raw primary_target_group_arn) 

popd > /dev/null

echo "Health-checking new environment..."
./scripts/health_check.sh "${HEALTH_URL:-http://example.com/health}" 10 6

echo "Switching ALB to new target group..."

aws elbv2 modify-listener \
  --listener-arn "${LISTENER_ARN}" \
  --default-actions "Type=forward,TargetGroupArn=${NEW_TG_ARN}"

echo "Traffic switched to green environment."

echo "Blue/Green deployment complete."
