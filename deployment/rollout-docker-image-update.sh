#!/bin/bash

# Variables
ZONE="us-central1-a"
INSTANCE_GROUP="go-server-mig"

# Validate variables
if [[ -z "$ZONE" || -z "$INSTANCE_GROUP" ]]; then
    echo "Error: ZONE or INSTANCE_GROUP is not set."
    exit 1
fi

# Execute rolling restart
gcloud compute instance-groups managed rolling-action restart "$INSTANCE_GROUP" \
  --zone="$ZONE"

# Check for success
if [ $? -eq 0 ]; then
    echo "Rolling restart initiated successfully for instance group: $INSTANCE_GROUP in zone: $ZONE"
else
    echo "Error: Failed to initiate rolling restart for instance group: $INSTANCE_GROUP in zone: $ZONE."
    exit 1
fi
