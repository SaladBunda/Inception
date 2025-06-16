#!/bin/bash

docker stop wordpresser

docker rm wordpresser
docker rmi wordpress

docker build -t wordpress .
docker run -d --name wordpresser -p 9000:9000 wordpress

