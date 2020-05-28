#!/bin/bash
set -e
set -o pipefail

# Wait for the ASG to run at the expected scale.
while true; do
  REGION=$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/[a-zA-Z]$//')
  INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
  ASG_NAME=$(aws autoscaling describe-auto-scaling-instances --region="$REGION" --instance-ids="$INSTANCE_ID" | jq -r ".AutoScalingInstances[0] .AutoScalingGroupName")
  ASG_DESCRIPTION=$(aws autoscaling describe-auto-scaling-groups --region="$REGION" --auto-scaling-group-names="$ASG_NAME")
  # shellcheck disable=SC2181
  if [ $? -ne 0 ]; then
    sleep 15
    continue
  fi
  ASG_DESIRED_CAP=$(echo "$ASG_DESCRIPTION" | jq ".AutoScalingGroups[0] .DesiredCapacity")
  ASG_INSTANCE_IDS=$(echo "$ASG_DESCRIPTION" | jq -r ".AutoScalingGroups[0] .Instances | sort_by(.InstanceId) | .[].InstanceId")
  ASG_CURRENT_CAP=$(echo -e "$ASG_INSTANCE_IDS" | wc -l)

  if [ "$ASG_CURRENT_CAP" == "$ASG_DESIRED_CAP" ]; then
    break
  fi

  echo "Waiting for the ASG to be at desired capacity (Desired: $ASG_DESIRED_CAP, Current: $ASG_CURRENT_CAP)"
  sleep 15
done

# shellcheck disable=SC2154,SC2086
if [ "${master_elb_enabled}" == "true" ]; then
  API_HEALTHY=$(aws elbv2 describe-target-health --region="$REGION" --target-group-arn ${target_group_arn} | jq -r '[ .TargetHealthDescriptions[].TargetHealth | select(.State | contains("healthy")) ] | length > 1')
else
  API_HEALTHY=$(if curl -k -L --silent --output /dev/null ${k8s_api_url}; then echo "true"; else echo "false"; fi)
fi

if [ "$API_HEALTHY" == "true" ]; then
    echo "Healthy API instances found, cluster is already installed."
    echo -n "false" >/run/metadata/master
    exit 0
fi

BOOTKUBE_MASTER=$(echo "$ASG_INSTANCE_IDS" | head -n1)

if [ "$BOOTKUBE_MASTER" != "$INSTANCE_ID" ]; then
    echo "This instance is not the bootkube master, '$BOOTKUBE_MASTER' is."
    echo -n "false" >/run/metadata/master
    exit 0
fi

echo -n "true" >/run/metadata/master
