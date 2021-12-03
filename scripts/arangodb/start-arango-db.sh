#!/bin/bash

set -e

if [ $1 == "test_arango" ];
then
  echo "Setting up test data for ArangoDB";
  PROJECT_ROOT_PATH="$PWD";
  echo "PROJECT_ROOT_PATH: $PROJECT_ROOT_PATH"
  ARANGO_DOCKER_LOCAL_DIR="../arango-volume-share";
  ARANGO_DOCKER_VOLUME_DESTINATION="/home/arango-volume-share";

  # Create arango volume share location
  if [ -d "$ARANGO_DOCKER_LOCAL_DIR" ]; then
    echo "Removing $ARANGO_DOCKER_LOCAL_DIR"
    rm -rf "$ARANGO_DOCKER_LOCAL_DIR"
  fi

  mkdir $ARANGO_DOCKER_LOCAL_DIR
  echo "Created local Docker share directory $ARANGO_DOCKER_LOCAL_DIR"

  # Copy Arango Test Data to local share location
  cp -R ./scripts/arango $ARANGO_DOCKER_LOCAL_DIR
  echo "Copied scripts to local Docker share directory $ARANGO_DOCKER_LOCAL_DIR"
  cd $ARANGO_DOCKER_LOCAL_DIR

  ARANGO_LOCAL_VOLUME_PATH="$PWD";
  echo "ARANGO_LOCAL_VOLUME_PATH: $ARANGO_LOCAL_VOLUME_PATH"

  cd $PROJECT_ROOT_PATH
fi

if [ $ARANGO_LOCAL_VOLUME_PATH != "" ];
then
  ARANGO_LOCAL_VOLUME_PATH_CMD=" -v $ARANGO_LOCAL_VOLUME_PATH:$ARANGO_DOCKER_VOLUME_DESTINATION";
  echo "ARANGO_LOCAL_VOLUME_PATH_CMD: $ARANGO_LOCAL_VOLUME_PATH_CMD"
else
  ARANGO_LOCAL_VOLUME_PATH_CMD="";
fi

# Remember to set the following environment variables and to add their values to your .env in project root.
# ARANGO_DB_SERVER="dbserver";
# ARANGO_DB_PORT="8529";
# ARANGO_DB_ROOT_PASSWORD="rootPASSWORD";
# ARANGO_DB_USER="devtester";
# ARANGO_DB_USER_PASSWORD="confidential"
# ARANGO_DB_NAME="testdb";

echo "stop & remove old docker [$ARANGO_DB_SERVER] and starting new fresh instance of [$ARANGO_DB_SERVER]"
(sudo -u root docker container stop $ARANGO_DB_SERVER || :) && \
  (sudo -u root docker container rm $ARANGO_DB_SERVER || :) && \
  sudo -u root docker run -e ARANGO_ROOT_PASSWORD=$ARANGO_DB_ROOT_PASSWORD \
  -e ARANGO_TEST_USER_PASSWORD=$ARANGO_DB_USER_PASSWORD \
  --name $ARANGO_DB_SERVER -p $ARANGO_DB_PORT:8529 -d$ARANGO_LOCAL_VOLUME_PATH_CMD \
  arangodb

# wait for pg to start
echo "sleep wait for arango-db-server [$ARANGO_DB_SERVER] to start";
sudo -u root docker ps | grep "$ARANGO_DB_SERVER"
wait

echo "Run setup script to load test data"
STARTUP_SCRIPT="$ARANGO_DOCKER_VOLUME_DESTINATION/arango/arango-setup.sh"
sudo -u root docker exec -it $ARANGO_DB_SERVER $STARTUP_SCRIPT
