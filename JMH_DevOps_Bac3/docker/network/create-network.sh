#!/usr/bin/env bash
set -e
docker network inspect jmh-net >/dev/null 2>&1 || docker network create jmh-net
docker run -d --name jmh-network-test --network jmh-net nginx:alpine
docker network inspect jmh-net
