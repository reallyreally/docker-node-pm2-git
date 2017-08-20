# docker-node-pm2-git
Docker container to fetch code from public/private repos with key where needed

Launch a git hosted node project with something like:
```
docker run -it --env NPM_TOKEN=aaaaaaaa-bbbb-0000-0a0a-ffffeeee8888 --env REPO_KEY="$(cat ~/.ssh/my-repo-key)" --env REPO="git@github.com:reallyreally/node-expressjs-service.git" --env PORT=8080 really/node-pm2-git ./bin/www
```
