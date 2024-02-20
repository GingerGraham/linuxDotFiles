#!/bin/bash

# Path: testing/cleanup.sh
# Purpose: Remove the Docker image and container created by the testing script and remove the dockerfile
# Use: Run this script to remove the Docker image and container created by the testing script and remove the dockerfile

# Remove all dotfiletest containers
docker ps -a | grep "dotfiletest" | awk '{print $1}' | xargs -I {} docker rm -f {}

# Remove all dotfiletest images
docker images | grep "dotfiletest" | awk '{print $3}' | xargs -I {} docker rmi -f {}

# Remove the dockerfile from the directory that this script is held in regardless of the current working directory
if [[ -f "$(dirname "${0}")"/dockerfile ]]; then
    rm "$(dirname "${0}")"/dockerfile
fi