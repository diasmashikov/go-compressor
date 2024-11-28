#!/bin/bash

# Load variables from .env
if [ -f .env ]; then
  source .env
else
  echo ".env file not found. Please create one with required variables."
  exit 1
fi

# Build the Docker image for linux/amd64
docker build --file Dockerfile --platform linux/amd64 -t ${CONTAINER_NAME}:${VERSION} ..

# Tag for GCP
docker tag ${CONTAINER_NAME}:${VERSION} ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${CONTAINER_NAME}:${VERSION}
docker tag ${CONTAINER_NAME}:${VERSION} ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${CONTAINER_NAME}:latest

# Authenticate with GCP
gcloud auth configure-docker ${REGION}-docker.pkg.dev

# Push tags to GCP
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${CONTAINER_NAME}:${VERSION}
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${CONTAINER_NAME}:latest

echo "Image successfully pushed with tags: ${VERSION} and latest!"
