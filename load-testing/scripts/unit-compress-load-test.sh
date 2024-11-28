#!/bin/bash

# Create k6 network if it doesn't exist
docker network create k6-network 2>/dev/null || true

# Run k6 container
docker run --rm \
  --network k6-network \
  -v "$(pwd)/tests/k6:/scripts" \
  -v "$(pwd)/tests/k6/scenarios/test-images:/scripts/scenarios/test-images" \
  -e API_HOST=host.docker.internal \
  grafana/k6:latest run /scripts/scenarios/compress.js