#!/usr/bin/env sh

if [ -z "$NODE_ENV" ]; then
  NODE_ENV=production
fi

if [ ! -d "/usr/src/app" ]; then
  if [ ! -z "$NPM_TOKEN" ]; then
    echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc
  fi
  if [ ! -z "$REPO_KEY" ]; then
    echo "${REPO_KEY}" > ~/.ssh/repo-key
  else
    rm -f ~/.ssh/repo-key ~/.ssh/config
  fi
  git clone $REPO /usr/src/app
  cd /usr/src/app
  npm install
fi

if [ -d "/usr/src/app" ]; then
  cd /usr/src/app
  pm2-docker $@
fi
