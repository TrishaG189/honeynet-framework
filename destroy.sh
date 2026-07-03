#!/bin/bash

# Initialize variables
CLOUD=""
REGION_OVERRIDE=""

# Parse flags manually to support positional independence (--cloud or --region first)
while [[ $# -gt 0 ]]; do
  case $1 in
    --cloud)
      CLOUD="$2"
      shift 2
      ;;
    --region)
      REGION_OVERRIDE="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Usage: ./destroy.sh --cloud [aws|gcp] [--region region_name]"
      exit 1
      ;;
  esac
done

# Validate user input
if [ -z "$CLOUD" ]; then
  echo "Error: Missing required argument --cloud."
  echo "Usage: ./destroy.sh --cloud [aws|gcp] [--region region_name]"
  exit 1
fi

case "$CLOUD" in
  "aws")
    echo "=========================================="
    echo "  Tearing Down AWS Multi-Region Network   "
    echo "=========================================="
    cd v3 || exit 1
    
    if [ -n "$REGION_OVERRIDE" ]; then
      echo "Applying custom region override for teardown: $REGION_OVERRIDE"
      # terraform destroy -var="target_region=$REGION_OVERRIDE" -auto-approve
    else
      echo "Destroying default primary/secondary architecture instances..."
      # terraform destroy -auto-approve
    fi
    echo "AWS teardown simulation completed."
    ;;

  "gcp")
    echo "=========================================="
    echo "   Tearing Down Google Cloud Network      "
    echo "=========================================="
    cd v4 || exit 1
    
    if [ -n "$REGION_OVERRIDE" ]; then
      echo "Applying custom region override for teardown: $REGION_OVERRIDE"
      # terraform destroy -var="region=$REGION_OVERRIDE" -auto-approve
    else
      echo "Destroying default Google Cloud infrastructure..."
      # terraform destroy -auto-approve
    fi
    echo "GCP teardown simulation completed."
    ;;

  *)
      echo "Unknown argument: $1"
      echo "Usage: ./deploy.sh --cloud [aws|gcp] [--region region_name]"
      exit 1
      ;;
  esac
done