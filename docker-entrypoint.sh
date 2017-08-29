#!/usr/bin/env sh

if [ -z "$NODE_ENV" ]; then
  NODE_ENV=production
  export NODE_ENV
fi

if [ ! -d "/usr/src/app" ]; then

  if [ ! -z "$NPM_TOKEN" ]; then
    echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > /root/.npmrc
  fi

  if [ ! -z "$REPO_KEY" ]; then
    echo "Storing private key as /root/.ssh/repo-key"
    echo "${REPO_KEY}" > /root/.ssh/repo-key
  fi

  if [ ! -z "$GIT_BRANCH" ]; then
    GITBRANCHCMD="-b ${GIT_BRANCH}"
  else
    GITBRANCHCMD=""
  fi

  if [ ! -s "/root/.ssh/repo-key" ]; then
    echo "No private key provided - removing configuration"
    rm -f /root/.ssh/repo-key /root/.ssh/config
  fi

  echo "Cloning ${REPO}"
  git clone $GITBRANCHCMD $REPO /usr/src/app
  if [ -f "/usr/src/app/package.json" ]; then
    cd /usr/src/app
    npm install
    ls -al
  else
    echo "Failed to fetch repository"
  fi

fi

if [ -d "/usr/src/app" ]; then
  cd /usr/src/app
  pm2-docker $@
else
  echo "There is no NodeJS application installed"
  "$@"
fi
