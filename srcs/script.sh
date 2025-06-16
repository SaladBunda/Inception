#!/bin/bash

docker stop nginx
docker stop mariadb
docker stop wordpress

docker rm -f nginx
docker rm -f mariadb
docker rm -f wordpress

docker rmi -f srcs_nginx
docker rmi -f srcs_mariadb
docker rmi -f srcs_wordpress
