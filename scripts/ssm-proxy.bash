#!/usr/bin/env bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# Configuration
# Change these values to reflect your environment
AWS_PROFILE="${AWS_PROFILE:=cloud9}"
AWS_REGION="${AWS_REGION:=us-east-1}"
MAX_ITERATION=5
SLEEP_DURATION=5

# Arguments passed from SSH client
HOST=$1
PORT=$2

getInstanceStatus() {
  aws ssm describe-instance-information --filters Key=InstanceIds,Values="${HOST}" \
    --output text --query 'InstanceInformationList[0].PingStatus' \
    --profile "${AWS_PROFILE}" --region "${AWS_REGION}"
}

COUNT=0
while [ "$(getInstanceStatus)" != 'Online' ]; do
  if [ "${COUNT}" -eq 0 ]; then
    # Instance is offline, start the instance.
    aws ec2 start-instances --instance-ids "${HOST}" --profile "${AWS_PROFILE}" --region "${AWS_REGION}"
  fi
  if [ "${COUNT}" -eq "${MAX_ITERATION}" ]; then
    # Max attempts reached, exit
    exit 1
  fi
  let COUNT=COUNT+1
  sleep "${SLEEP_DURATION}"
done

# Instance is online, start the session.
aws ssm start-session --target "${HOST}" --document-name AWS-StartSSHSession \
  --parameters portNumber="${PORT}" --profile "${AWS_PROFILE}" --region "${AWS_REGION}"
