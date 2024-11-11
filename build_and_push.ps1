#!/bin/bash
# Run this commented command once if you never initalized a buildx container before
# docker buildx create --use --name build --node build --driver-opt network=host

$PIHOLE_VER = Get-Content -Raw VERSION

docker buildx build --build-arg PIHOLE_VERSION=$PIHOLE_VER --pull --rm -f "Dockerfile" --platform linux/arm/v7,linux/arm64/v8,linux/amd64 -t nyirsh/pihole-unbound:experimental "pihole-unbound" --push