#!/bin/bash

# 1. Validate user input
if [ -z "$1" ]; then
  echo "Usage: ./destroy.sh [region|all]"
  echo "Available regions: us-east-1, eu-central-1, ap-south-1, all"
  exit 1
fi

REGION=$1

# 2. Route the destruction based on the input
case $REGION in
  "us-east-1")
    echo "Destroying US East (N. Virginia)..."
    terraform destroy -target=module.network_us -target=module.compute_us -auto-approve
    ;;
  "eu-central-1")
    echo "Destroying Europe (Frankfurt)..."
    terraform destroy -target=module.network_eu -target=module.compute_eu -auto-approve
    ;;
  "ap-south-1")
    echo "Destroying Asia Pacific (Mumbai)..."
    terraform destroy -target=module.network_in -target=module.compute_in -auto-approve
    ;;
  "all")
    echo "Destroying ALL regions..."
    terraform destroy -auto-approve
    ;;
  *)
    echo "Error: Invalid region specified."
    echo "Available regions: us-east-1, eu-central-1, ap-south-1, all"
    exit 1
    ;;
esac