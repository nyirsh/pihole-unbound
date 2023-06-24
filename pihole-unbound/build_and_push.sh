#!/bin/bash
# Run this once: docker buildx create --use --name build --node build --driver-opt network=host
PIHOLE_VER=`cat VERSION`

docker buildx build --build-arg PIHOLE_VERSION=$PIHOLE_VER --pull --rm -f "Dockerfile" --platform linux/arm/v7,linux/arm64/v8,linux/amd64 -t nyirsh/pihole-unbound:$PIHOLE_VER "pihole-unbound" --push
docker buildx build --build-arg PIHOLE_VERSION=$PIHOLE_VER --pull --rm -f "Dockerfile" --platform linux/arm/v7,linux/arm64/v8,linux/amd64 -t nyirsh/pihole-unbound:latest "pihole-unbound" --push