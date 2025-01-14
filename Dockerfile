FROM node:10.15-slim
LABEL MAINTAINER https://github.com/DIYgod/RSSHub/

WORKDIR /app

COPY sources.list /app
COPY libvips-8.8.1-linux-x64.tar.gz /app

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && mv /app/sources.list /etc/apt/sources.list && apt-get update && apt-get install -yq libgconf-2-4 apt-transport-https git --no-install-recommends && apt-get clean \
  && rm -rf /var/lib/apt/lists/* && mkdir -p /root/.npm/_libvips && cp /app/libvips-8.8.1-linux-x64.tar.gz /root/.npm/_libvips/libvips-8.8.1-linux-x64.tar.gz

ENV NODE_ENV production
ENV TZ Asia/Shanghai


COPY package.json /app

ARG USE_CHINA_NPM_REGISTRY=1;

RUN if [ "$USE_CHINA_NPM_REGISTRY" = 1 ]; then \
  echo 'use npm mirror'; npm config set registry https://registry.npm.taobao.org; \
  fi;

ARG PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1;

RUN if [ "$PUPPETEER_SKIP_CHROMIUM_DOWNLOAD" = 0 ]; then \
  apt-get install -y wget --no-install-recommends \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
  --no-install-recommends \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get purge --auto-remove -y curl \
  && rm -rf /src/*.deb \
  && npm install --production; \
  else \
  export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true && \
  npm install --production; \
  fi;

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

COPY . /app

EXPOSE 1200
ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "run", "start"]
