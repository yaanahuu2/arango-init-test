#!/bin/sh

arangosh \
--server.password $ARANGO_ROOT_PASSWORD \
--console.history false \
--javascript.execute /home/arango-volume-share/arango/setup.js
