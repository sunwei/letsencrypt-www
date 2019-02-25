#!/bin/bash
set -e

source secrets/docker-hub
echo $docker_username

echo "Logging docker into docker hub registry..."
echo $docker_password | \
docker login --username=$docker_username --password-stdin

echo "Pushing docker into docker hub..."
docker tag letsencrypt:latest sunzhongmou/letsencrypt:latest
docker push sunzhongmou/letsencrypt:latest