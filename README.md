# really/node-pm2-git
_DANGER_ This is a testing image and will reveal keys
Docker container to fetch code from public/private repos with key where needed

[![](https://images.microbadger.com/badges/image/really/node-pm2-git.svg)](https://microbadger.com/images/really/node-pm2-git "Get your own image badge on microbadger.com") [![GitHub issues](https://img.shields.io/github/issues/reallyreally/docker-node-pm2-git.svg?style=flat-square)](https://github.com/reallyreally/docker-node-pm2-git/issues) [![GitHub license](https://img.shields.io/github/license/reallyreally/docker-node-pm2-git.svg?style=flat-square)](https://github.com/reallyreally/docker-node-pm2-git/blob/master/LICENSE) [![Docker Pulls](https://img.shields.io/docker/pulls/really/node-pm2-git.svg?style=flat-square)](https://github.com/reallyreally/docker-node-pm2-git/)

Launch a git hosted node project with something like:
```
docker run -d -p 8080:8080 \
  --env NPM_TOKEN=aaaaaaaa-bbbb-0000-0a0a-ffffeeee8888 \
  --env REPO_KEY="$(cat ~/.ssh/my-repo-key)" \
  --env REPO="git@github.com:reallyreally/node-expressjs-service.git" \
  --env GIT_BRANCH="production-live" \
  --env KEYMETRICS_PUBLIC=0000aaaa1111ffff \
  --env KEYMETRICS_SECRET=0123456789abcdef \
  --env PORT=8080 \
  really/node-pm2-git ./pm2.json
```

Environment variables
---------------------

`NPM_TOKEN` allows to use private [npmjs.com](https://www.npmjs.com) packages (optional)
`REPO_KEY` read in a file to be used as the key for your repository clone (optional)
`REPO` the repository to clone (required)
`GIT_BRANCH` the branch to clone (optional)
`KEYMETRICS_PUBLIC` & `KEYMETRICS_SECRET` if you use [keymetrics.io](https://keymetrics.io) (optional)

App Startup
-----------

In the example we call `./pm2.json` which could contain the below.

```
{
  "apps": [{
    "name": "node-expressjs-service",
    "script": "./bin/www",
    "instances" : 0,
    "exec_mode" : "cluster",
    "post_update": ["npm install", "echo Launching..."],
    "env": {
      "production": true
    }
  }]
}
```

If you do not want to use `./pm2.json` You equally could just replace it with `./bin/www` for a typical [ExpressJS](https://ExpressJS.com) application (you will loose the ability to configure PM2 clustering etc).
