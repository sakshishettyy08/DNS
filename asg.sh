#!/bin/bash

# ====== CONFIGURATION ======
ASG_NAME="sakshi-asg-assignment"
LAUNCH_TEMPLATE_NAME="sakshi-assignment-3"
TARGET_GROUP_ARN="arn:aws:elasticloadbalancing:us-east-1:866934333672:targetgroup/sakshi-lb-group/2d5d28f559553b2c"
VPC_SUBNETS="subnet-01580015c27766c68,subnet-07b197340740cbb24"  
REGION="us-east-1"
YOUR_NAME="sakshi"

# ====== CREATE AUTO SCALING GROUP ======
echo "Creating Auto Scaling Group: $ASG_NAME"
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name "$ASG_NAME" \
  --launch-template "LaunchTemplateName=$LAUNCH_TEMPLATE_NAME,Version=\$Latest" \
  --min-size 1 \
  --max-size 4 \
  --desired-capacity 2 \
  --vpc-zone-identifier "$VPC_SUBNETS" \
  --target-group-arns "$TARGET_GROUP_ARN" \
  --tags "Key=Name,Value=${YOUR_NAME}-alb-asg-instance,PropagateAtLaunch=true" \
         "Key=owner,Value=${YOUR_NAME},PropagateAtLaunch=true" \
  --region "$REGION"

# ====== ADD TARGET TRACKING SCALING POLICY ======

aws autoscaling put-scaling-policy \
  --policy-name "${ASG_NAME}-cpu-tracking-policy" \
  --auto-scaling-group-name "$ASG_NAME" \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "PredefinedMetricSpecification": {
        "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "TargetValue": 50.0
  }' \
  --estimated-instance-warmup 300 \
  --region "$REGION"
