#!/bin/bash
set -e
set -o pipefail
REGION=$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/[a-zA-Z]$//')
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
SPOT_REQ_ID=$(aws --region "$REGION" ec2 describe-spot-instance-requests --filters Name=instance-id,Values="$INSTANCE_ID" | jq -Mr .SpotInstanceRequests[0].SpotInstanceRequestId)

aws --region "$REGION" ec2 describe-spot-instance-requests --spot-instance-request-ids "$SPOT_REQ_ID" | jq -Mr .SpotInstanceRequests[0].Tags > tags.json
aws --region "$REGION" ec2 create-tags --resources "$INSTANCE_ID" --tags file://tags.json


