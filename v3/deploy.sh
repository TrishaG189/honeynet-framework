#!/bin/bash

# 1. Validate user input
if [ -z "$1" ]; then
  echo "Usage: ./deploy.sh [region|all]"
  echo "Available regions: us-east-1, eu-central-1, ap-south-1, all"
  exit 1
fi

REGION=$1

# 2. Route the deployment based on the input
case $REGION in
  "us-east-1")
    echo "Deploying to US East (N. Virginia)..."
    terraform apply -target=module.network_us -target=module.compute_us -auto-approve
    ;;
  "eu-central-1")
    echo "Deploying to Europe (Frankfurt)..."
    terraform apply -target=module.network_eu -target=module.compute_eu -auto-approve
    ;;
  "ap-south-1")
    echo "Deploying to Asia Pacific (Mumbai)..."
    terraform apply -target=module.network_in -target=module.compute_in -auto-approve
    ;;
  "all")
    echo "Deploying to ALL regions..."
    terraform apply -auto-approve
    ;;
  *)
    echo "Error: Invalid region specified."
    echo "Available regions: us-east-1, eu-central-1, ap-south-1, all"
    exit 1
    ;;
esac