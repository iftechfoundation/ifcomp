#!/bin/sh

ID=$(docker ps -f name=ifcomp-dev_app --format '{{.ID}}')
docker exec -it $ID bash
