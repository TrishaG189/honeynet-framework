#!/bin/bash
CLOUD=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cloud) CLOUD="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ "$CLOUD" == "aws" ]; then
    echo "Initializing remote state and destroying AWS Infrastructure..."
    cd v3 || exit
    terraform init
    terraform destroy -target=module.network_in -target=module.compute_in -auto-approve
elif [ "$CLOUD" == "gcp" ]; then
    echo "Initializing remote state and destroying GCP Infrastructure..."
    cd v4 || exit
    terraform init
    terraform destroy -auto-approve
else
    echo "Error: Please specify a cloud provider. Usage: ./destroy.sh --cloud aws | gcp"
    exit 1
fi