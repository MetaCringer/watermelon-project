#!/bin/bash
set -e
set -m
cd master
docker build --no-cache -t mc-master . 
cd ../slave 
docker build --no-cache -t mc-slave . 
docker tag mc-master $1
docker tag mc-slave $2
docker push $1 &
docker push $2 &
