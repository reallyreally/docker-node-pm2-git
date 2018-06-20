FROM alpine:latest

MAINTAINER Troy Kelly <troy.kelly@really.ai>

ENV VERSION=v9.11.2 NPM_VERSION=5.6.0 YARN_VERSION=latest

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Node.JS with PM2 and git" \
      org.label-schema.description="Provides node with working pm2 and git. Supports starting apps from pm2.json with feedback to keymetrics." \
      org.label-schema.url="https://really.ai/about/opensource" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/reallyreally/docker-node-pm2-git" \
      org.label-schema.vendor="Really Really, Inc." \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

# For base builds
#ENV CONFIG_FLAGS="--fully-static --without-npm" DEL_PKGS="libstdc++" RM_DIRS=/usr/include

RUN apk update && \
  apk add --no-cache openssh-client git curl make gcc g++ python linux-headers binutils-gold gnupg libstdc++ && \
  for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D; \
  do \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
  done && \
  curl -SLO "https://nodejs.org/dist/$VERSION/node-$VERSION.tar.xz" && \
  curl -SLO --compressed "https://nodejs.org/dist/$VERSION/SHASUMS256.txt.asc" && \
  gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc && \
  grep " node-$VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - && \
  tar -xf node-${VERSION}.tar.xz && \
  cd node-${VERSION} && \
  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(getconf _NPROCESSORS_ONLN) && \
  make install && \
  cd / && \
  if [ -z "$CONFIG_FLAGS" ]; then \
    npm install -g npm@${NPM_VERSION} && \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf && \
    if [ -n "$YARN_VERSION" ]; then \
      gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys \
        6A010C5166006599AA17F08146C2130DFD2497F5 && \
      curl -sSL -O https://yarnpkg.com/${YARN_VERSION}.tar.gz -O https://yarnpkg.com/${YARN_VERSION}.tar.gz.asc && \
      gpg --batch --verify ${YARN_VERSION}.tar.gz.asc ${YARN_VERSION}.tar.gz && \
      mkdir /usr/local/share/yarn && \
      tar -xf ${YARN_VERSION}.tar.gz -C /usr/local/share/yarn --strip 1 && \
      ln -s /usr/local/share/yarn/bin/yarn /usr/local/bin/ && \
      ln -s /usr/local/share/yarn/bin/yarnpkg /usr/local/bin/ && \
      rm ${YARN_VERSION}.tar.gz*; \
    fi; \
  fi && \
  apk del curl make gcc g++ python linux-headers binutils-gold gnupg ${DEL_PKGS} && \
  rm -rf ${RM_DIRS} /node-${VERSION}* /usr/share/man /tmp/* /var/cache/apk/* \
    /root/.npm /root/.node-gyp /root/.gnupg /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts && \
  mkdir -p /usr/src && \
  mkdir /root/.ssh && \
  touch /root/.ssh/repo-key && \
  echo "IdentityFile /root/.ssh/repo-key" > /root/.ssh/config && \
  chmod 600 /root/.ssh/config && \
  chmod 600 /root/.ssh/repo-key && \
  npm install pm2 -g && \
  pm2 install pm2-auto-pull && \
  pm2 set pm2-auto-pull:interval 60000

COPY known_hosts /root/.ssh/known_hosts
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
