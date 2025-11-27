#!/usr/bin/env bash
set -euo pipefail


CANARY_PERCENT="${CANARY_PERCENT:-10}"
VERSION="${1:-$(date +%s)}"
TF_DIR="${TF_DIR:-../terraform}"

WORKSPACE="canary-${VERSION}"
pushd "$TF_DIR" > /dev/null
terraform workspace new "$WORKSPACE" || terraform workspace select "$WORKSPACE"
terraform init -input=false
terraform apply -auto-approve -var="app_image_tag=${VERSION}"
LISTENER_ARN=$(terraform output -raw alb_listener_arn) || true
CANARY_TG_ARN=$(terraform output -raw primary_target_group_arn) || true
popd > /dev/null

if [ -z "${LISTENER_ARN:-}" ]; then
  echo "Missing LISTENER_ARN — export it or ensure TF outputs it."
  exit 1
fi
if [ -z "${CANARY_TG_ARN:-}" ]; then
  echo "Missing CANARY_TG_ARN — export it or ensure TF outputs it."
  exit 1
fi

pushd "$TF_DIR" > /dev/null
terraform workspace select default || true
PRIMARY_TG_ARN=$(terraform output -raw primary_target_group_arn) || true
popd > /dev/null

if [ -z "${PRIMARY_TG_ARN:-}" ]; then
  echo "Missing PRIMARY_TG_ARN — export it or ensure it's output by terraform in the default workspace."
  exit 1
fi

PRIMARY_WEIGHT=$((100 - CANARY_PERCENT))
CANARY_WEIGHT="$CANARY_PERCENT"

echo "Setting listener to forward ${CANARY_WEIGHT}% to canary, ${PRIMARY_WEIGHT}% to primary."

aws elbv2 modify-listener \
  --listener-arn "${LISTENER_ARN}" \
  --default-actions "Type=forward,ForwardConfig={TargetGroups=[{TargetGroupArn=${PRIMARY_TG_ARN},Weight=${PRIMARY_WEIGHT}},{TargetGroupArn=${CANARY_TG_ARN},Weight=${CANARY_WEIGHT}}],TargetGroupStickinessConfig={Enabled=false}}"

echo "Canary in place. Monitor metrics. Use the same command to increase canary weight or set it to 100 to promote."

