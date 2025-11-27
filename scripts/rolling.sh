#!/usr/bin/env bash
set -euo pipefail


ASG_NAME="${ASG_NAME:-my-app-asg}"   # change or export before calling
MIN_HEALTH_PERCENT="${MIN_HEALTH_PERCENT:-90}"  # e.g. 90 means at least 90% healthy during refresh
TF_DIR="${TF_DIR:-../terraform}"

if [ -z "${ASG_NAME}" ] || [ "${ASG_NAME}" == "my-app-asg" ]; then
  echo "Using ASG_NAME=${ASG_NAME}. Make sure it's correct (export ASG_NAME if needed)."
fi

echo "Starting instance refresh for ASG: ${ASG_NAME} (MinHealthyPercentage=${MIN_HEALTH_PERCENT})"

aws autoscaling start-instance-refresh \
  --auto-scaling-group-name "${ASG_NAME}" \
  --preferences '{"MinHealthyPercentage":'"${MIN_HEALTH_PERCENT}"'}'

echo "Instance refresh started. Use 'aws autoscaling describe-instance-refreshes --auto-scaling-group-name ${ASG_NAME}' to track progress."
