#!/bin/bash
set -eux

LISTENER_ARN="$1"
TG_BLUE_ARN="$2"
TG_GREEN_ARN="$3"

if [[ -z "$LISTENER_ARN" || -z "$TG_BLUE_ARN" || -z "$TG_GREEN_ARN" ]]; then
  echo "Usage: $0 <listener_arn> <tg_blue_arn> <tg_green_arn>"
  exit 2
fi

# Restore traffic to blue (100%)
aws elbv2 modify-listener \
  --listener-arn "$LISTENER_ARN" \
  --default-actions Type=forward,ForwardConfig="{TargetGroups=[{TargetGroupArn=$TG_BLUE_ARN,Weight=100},{TargetGroupArn=$TG_GREEN_ARN,Weight=0}],TargetGroupStickinessConfig={Enabled=false}}"

# scale green down
GREEN_ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?contains(Tags[?Key=='Name'].Value | [0], 'green')].[AutoScalingGroupName] | [0][0]" --output text)
if [[ -n "$GREEN_ASG_NAME" && "$GREEN_ASG_NAME" != "None" ]]; then
  aws autoscaling set-desired-capacity --auto-scaling-group-name "$GREEN_ASG_NAME" --desired-capacity 0 --honor-cooldown
fi

echo "Rollback completed: traffic restored to blue and green scaled down."
