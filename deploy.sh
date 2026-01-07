#!/usr/bin/env bash
set -euo pipefail

: "${DEPLOY_HOST:?missing DEPLOY_HOST}"
: "${DEPLOY_USER:?missing DEPLOY_USER}"
: "${DEPLOY_SSH_KEY_BASE64:?missing DEPLOY_SSH_KEY_BASE64}"
: "${DOCKER_REGISTRY:?missing DOCKER_REGISTRY}"
: "${DOCKER_USERNAME:?missing DOCKER_USERNAME}"
: "${DOCKER_PASSWORD:?missing DOCKER_PASSWORD}"
: "${DOCKER_IMAGE:?missing DOCKER_IMAGE}"

IMAGE_TAG="${BUILDKITE_COMMIT}"

# Prepare SSH key
mkdir -p ~/.ssh
echo "$DEPLOY_SSH_KEY_BASE64" | base64 -d > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

SSH_OPTS="-o StrictHostKeyChecking=no -i ~/.ssh/id_rsa"

ssh $SSH_OPTS "${DEPLOY_USER}@${DEPLOY_HOST}" bash -s <<EOF
set -euo pipefail

docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD" "$DOCKER_REGISTRY"

docker pull "$DOCKER_IMAGE:$IMAGE_TAG"

# Stop old container if exists
docker rm -f flask-api >/dev/null 2>&1 || true

# Run new container (adjust port/env as needed)
docker run -d --name flask-api \
  -p 8080:8080 \
  -e FLASK_ENV=production \
  "$DOCKER_IMAGE:$IMAGE_TAG"

docker image prune -f >/dev/null 2>&1 || true
EOF

echo "Deployed $DOCKER_IMAGE:$IMAGE_TAG to $DEPLOY_HOST"