#!/bin/bash
set -e

get_commit_count() {
  git rev-list --all --count
}

source secrets/docker-hub.env
echo "> Logging docker hub with user: ${DOCKER_USERNAME}"

echo "${DOCKER_PASSWORD}" | \
docker login --username="${DOCKER_USERNAME}" --password-stdin

echo "> Pushing image to docker hub..."
docker tag letsencrypt-www:latest sunzhongmou/letsencrypt-www:latest
docker push sunzhongmou/letsencrypt-www:latest

docker tag sunzhongmou/letsencrypt-www:latest "sunzhongmou/letsencrypt-www:$(get_commit_count)"
docker push "sunzhongmou/letsencrypt-www:$(get_commit_count)"