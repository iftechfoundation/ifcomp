#!/bin/sh

ID=$(docker ps -f name=ifcomp_web --format '{{.ID}}')
docker exec -it $ID bash
