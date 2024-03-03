#!/bin/bash

docker-compose down --remove-orphans

docker rm -f $(docker ps -a -q)

docker rmi -f $(docker images)

docker volume prune
