#!/bin/sh

echo '\nCleaning up previous setup...';
docker container rm --force craft-db;
docker container rm --force craft-cms;
docker volume rm craftdb;
rm -rf ./www;

echo '\nBringing up containers...';
docker run \
  --name craft-db \
  --env-file ./env/.mysql.env \
  --mount type=volume,source=craftdb,target=/var/lib/mysql \
  --detach \
  mariadb:10.3;

docker run \
  --name craft-cms \
  --env-file ./env/.craft.env \
  --link craft-db:db \
  --publish 8000:80 \
  --detach \
  myerscourtney/craft3:1.0;

sleep 15;

echo '\nCopying /srv/www directory from craft-cms container...';
docker cp craft-cms:/srv/www "$(PWD)"/www;

echo '\nBringing down and removing craft-cms container...';
docker container rm --force craft-cms;

echo '\nBringing up craft-cms container with bound volume...';
docker run \
  --name craft-cms \
  --env-file ./env/.craft.env \
  --mount type=bind,source=$PWD/www,target=/srv/www \
  --link craft-db:db \
  --publish 8000:80 \
  --detach \
  myerscourtney/craft3:1.0;

sleep 15;

echo '\nRestarting apache on craft-cms container...';
docker exec -it --detach craft-cms sh -c "/usr/sbin/httpd -D FOREGROUND";

echo '\nVisit site: http://localhost:8000/admin';
echo '\n';
