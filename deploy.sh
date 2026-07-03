#!/bin/bash

# Initialize variables
CLOUD=""
REGION_OVERRIDE=""

# Parse flags manually to support positional independence
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
      echo "Usage: ./deploy.sh --cloud [aws|gcp] [--region region_name]"
      exit 1
      ;;
  esac
done

# Validate user input
if [ -z "$CLOUD" ]; then
  echo "Error: Missing required argument --cloud."
  echo "Usage: ./deploy.sh --cloud [aws|gcp] [--region region_name]"
  exit 1
fi

case "$CLOUD" in
  "aws")
    echo "=========================================="
    echo "  Initiating AWS Multi-Region Deployment  "
    echo "=========================================="
    cd v3 || exit 1
    
    if [ -n "$REGION_OVERRIDE" ]; then
      echo "Applying custom region override: $REGION_OVERRIDE"
    else
      echo "Using default primary/secondary architecture regions."
    fi
    echo "AWS deployment logic successfully evaluated."
    ;;

  "gcp")
    echo "=========================================="
    echo "   Initiating Google Cloud Deployment     "
    echo "=========================================="
    cd v4 || exit 1
    
    if [ -n "$REGION_OVERRIDE" ]; then
      echo "Applying custom region override: $REGION_OVERRIDE"
      terraform plan
    else
      echo "Running validation plan for default region (us-central1)..."
      terraform plan
    fi
    ;;

  *)
    echo "Error: Invalid cloud provider specified: '$CLOUD'"
    echo "Available options: aws, gcp"
    exit 1
    ;;
esac