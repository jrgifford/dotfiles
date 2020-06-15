#!/bin/bash

if [ "x$1" == "x" ]; then
    echo "Usage: $0 appname"
    exit 1
fi

set -euo pipefail

APP=$1

# Use API_DATABASE_RDS_URL here instead of connect to the prod_api db
DBURL=$(heroku config:get -a ${APP} MONOLITH_DATABASE_RDS_URL)

CERTF=$(mktemp ./XXXXXX)
KEYF=$(mktemp ./XXXXXX)
CAF=$(mktemp ./XXXXXX)

trap "rm -f $CERTF $KEYF $CAF" EXIT
chmod 0600 $CERTF $KEYF $CAF

heroku config:get -a ${APP} PGBOUNCER_SERVER_CERTFILE > $CERTF
heroku config:get -a ${APP} PGBOUNCER_SERVER_KEYFILE > $KEYF
heroku config:get -a ${APP} PGBOUNCER_SERVER_CAFILE > $CAF

CONNSTR="${DBURL}?sslmode=$(heroku config:get -a ${APP} PGBOUNCER_SSLMODE)"
CONNSTR+="&sslcert=$CERTF&sslkey=$KEYF&sslrootcert=$CAF"
psql "${CONNSTR}"

