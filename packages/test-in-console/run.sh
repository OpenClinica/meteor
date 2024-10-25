#!/usr/bin/env bash

# from Meteor local checkout run like
# ./packages/test-in-console/run.sh
# or for a specific package
# ./packages/test-in-console/run.sh "mongo"

cd $(dirname $0)/../..
export METEOR_HOME=`pwd`

export PATH=$METEOR_HOME:$PATH

PUPPETEER_EXISTS=`node -e "try { require('./dev_bundle/lib/node_modules/puppeteer'); console.log('true'); } catch (e) { console.log('false'); }"`

if [ "$PUPPETEER_EXISTS" = "false" ]; then
  echo "Installing puppeteer..."
  # Installs into dev_bundle/lib/node_modules/puppeteer.
  ./meteor npm install -g puppeteer@23.6.0
fi

export URL='http://127.0.0.1:4096/'
export METEOR_PACKAGE_DIRS='packages/deprecated'

exec 3< <(./meteor test-packages --driver-package test-in-console -p 4096 --exclude-archs=web.browser.legacy,web.cordova --exclude ${TEST_PACKAGES_EXCLUDE:-''} $1)
EXEC_PID=$!
trap "pkill -TERM -P $EXEC_PID; exit 1" SIGINT

sed '/test-in-console listening$/q' <&3

node --trace-warnings "$METEOR_HOME/packages/test-in-console/puppeteer_runner.js"

STATUS=$?

pkill -TERM -P $EXEC_PID
exit $STATUS
