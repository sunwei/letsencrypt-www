#!/bin/bash
set -e

source secrets/docker-hub.env
echo "> Logging docker hub with user: ${DOCKER_USERNAME}"

echo "${DOCKER_PASSWORD}" | \
docker login --username="${DOCKER_USERNAME}" --password-stdin
#
#echo "Pushing docker into aliyun..."
#docker tag letsencrypt-https:latest registry.cn-hangzhou.aliyuncs.com/szm/letsencrypt-https:latest
#docker push registry.cn-hangzhou.aliyuncs.com/szm/letsencrypt-https:latest