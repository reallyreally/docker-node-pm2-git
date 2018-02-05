#!/usr/bin/env sh
set -x

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
    printf "${REPO_KEY}" > /root/.ssh/repo-key
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
  if [ -d "/usr/src/app/.git" ]; then
    cd /usr/src/app || exit
    mkdir -pv /usr/src/app/.git/hooks
    printf "#!/usr/bin/env sh\nif [ -f \"/usr/src/app/package.json\" ]; then\n  cd /usr/src/app || exit\n  rm -Rf ./node_modules\n  npm install\nfi" > /usr/src/app/.git/hooks/post-merge
    chmod 555 /usr/src/app/.git/hooks/post-merge
    /usr/src/app/.git/hooks/post-merge
    ls -al
  else
    echo "Failed to fetch repository"
  fi

fi

if [ -d "/usr/src/app" ]; then
  cd /usr/src/app || exit
  pm2-docker $@
else
  echo "There is no NodeJS application installed"
  $@
fi
