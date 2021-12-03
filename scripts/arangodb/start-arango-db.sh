#!/bin/bash

set -e

if [ $1 == "test_arango" ];
then
  echo "Setting up seed data for ArangoDB";
  PROJECT_ROOT_PATH="$PWD";
  ARANGO_DOCKER_VOLUME_DESTINATION="/home/arango-volume-share";

  # Create arango volume share location
  mkdir ../../../arango-volume-share

  # Copy Arango Test Seed Data to share location
  cp -R ../arango ../../../arango-volume-share/
  cd ../../../arango-volume-share/

  ARANGO_VOLUME_PATH="$PWD";
  # echo $ARANGO_VOLUME_PATH

  cd $PROJECT_ROOT_PATH
fi

if [ $ARANGO_VOLUME_PATH != "" ];
then
  ARANGO_VOLUME_PATH_CMD = "-v $ARANGO_VOLUME_PATH:$ARANGO_DOCKER_VOLUME_DESTINATION";
else
  ARANGO_VOLUME_PATH_CMD = "";
fi

# Remember to set the following environment variables and to add their values to your .env in project root.
# ARANGO_DB_SERVER="dbserver";
# ARANGO_DB_ROOT_PASSWORD="rootPASSWORD";
# ARANGO_DB_USER="devtester";
# ARANGO_DB_USER_PASSWORD="confidential"
# ARANGO_DB_NAME="testdb";

echo "echo stop & remove old docker [$ARANGO_DB_SERVER] and starting new fresh instance of [$ARANGO_DB_SERVER]"
(docker kill $ARANGO_DB_SERVER || :) && \
  (docker rm $ARANGO_DB_SERVER || :) && \
  docker run -e ARANGO_ROOT_PASSWORD=$ARANGO_DB_ROOT_PASSWORD \
  -e ARANGO_TEST_USER_PASSWORD=$ARANGO_DB_USER_PASSWORD \
  --name $ARANGO_DB_SERVER -p $ARANGO_DB_PORT:8529 -d$ARANGO_VOLUME_PATH_CMD \
  arangodb

# wait for pg to start
echo "sleep wait for arango-db-server [$ARANGO_DB_SERVER] to start";
sleep 3;

# TODO
# create the db
# set environment variables
# create new db through arangosh

docker exec -it $ARANGO_DB_SERVER $ARANGO_DOCKER_VOLUME_DESTINATION/arango-setup.sh
