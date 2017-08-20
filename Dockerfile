# specify the node base image with your desired version node:<version>
FROM alpine:latest

MAINTAINER Troy Kelly <troy.kelly@really.ai>

RUN apk update && \
  apk add --no-cache libc6-compat nodejs-current-npm openssh-client git && \
  rm -rf /var/cache/apk/* && \
  mkdir -p /usr/src && \
  mkdir /root/.ssh && \
  touch /root/.ssh/repo-key && \
  echo "IdentityFile /root/.ssh/repo-key" > /root/.ssh/config && \
  chmod 600 /root/.ssh/config && \
  chmod 600 /root/.ssh/repo-key && \
  npm install pm2 -g && \
  pm2 install pm2-auto-pull

COPY known_hosts /root/.ssh/known_hosts
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
