# hadolint ignore=DL3007
FROM myoung34/github-runner-base:latest
LABEL maintainer="myoung34@my.apsu.edu"

ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
RUN mkdir -p /opt/hostedtoolcache

ARG GH_RUNNER_VERSION="2.311.0"

ARG TARGETPLATFORM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /actions-runner
COPY install_actions.sh /actions-runner

# Install dependencies
RUN apt-get update

# install convenience packages
RUN apt-get install -y ca-certificates 
RUN apt-get install -y curl 
RUN apt-get install -y gnupg 
RUN apt-get install -y jq 
RUN apt-get install -y git 
RUN apt-get install -y ftp 
RUN apt-get install -y libcurl4 
RUN apt-get install -y python3 
RUN apt-get install -y python3-pip 
RUN apt-get install -y python3-setuptools 
RUN apt-get install -y rsync 
RUN apt-get install -y sqlite3 
RUN apt-get install -y unzip 
RUN apt-get install -y wget 
RUN apt-get install -y zip 
RUN apt-get install -y tar 
RUN apt-get install -y time 
RUN apt-get install -y brotli 
RUN apt-get install -y bison 
RUN apt-get install -y php

# pupeeteer and cypress dependencies
RUN apt-get install -y chromium-bsu
RUN apt-get install -y firefox
RUN apt-get install -y libx11-xcb1
RUN apt-get install -y libxcomposite1
RUN apt-get install -y libasound2
RUN apt-get install -y libatk1.0-0
RUN apt-get install -y libatk-bridge2.0-0
RUN apt-get install -y libcairo2
RUN apt-get install -y libcups2
RUN apt-get install -y libdbus-1-3
RUN apt-get install -y libexpat1
RUN apt-get install -y libfontconfig1
RUN apt-get install -y libgbm1
RUN apt-get install -y libgcc1
RUN apt-get install -y libglib2.0-0
RUN apt-get install -y libgtk-3-0
RUN apt-get install -y libnspr4
RUN apt-get install -y libpango-1.0-0
RUN apt-get install -y libpangocairo-1.0-0
RUN apt-get install -y libstdc++6
RUN apt-get install -y libx11-6
RUN apt-get install -y libxcb1
RUN apt-get install -y libxcursor1
RUN apt-get install -y libxdamage1
RUN apt-get install -y libxext6
RUN apt-get install -y libxfixes3
RUN apt-get install -y libxi6
RUN apt-get install -y libxrandr2
RUN apt-get install -y libxrender1
RUN apt-get install -y libxss1
RUN apt-get install -y libxtst6
RUN apt-get install -y gconf-service
RUN apt-get install -y libc6
RUN apt-get install -y libgconf-2-4
RUN apt-get install -y libgdk-pixbuf2.0-0
RUN apt-get install -y ca-certificates
RUN apt-get install -y fonts-liberation
RUN apt-get install -y libappindicator1
RUN apt-get install -y libnss3
RUN apt-get install -y lsb-release
RUN apt-get install -y xdg-utils
RUN apt-get install -y xvfb

# Download and import the Nodesource GPG key
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# Create deb repository for Node.js 20.x
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Run update and install Node.js
RUN apt-get update \
  && apt-get install -y nodejs

# Install global npm packages
RUN npm install puppeteer cypress -g

RUN chmod +x /actions-runner/install_actions.sh \
  && /actions-runner/install_actions.sh ${GH_RUNNER_VERSION} ${TARGETPLATFORM} \
  && rm /actions-runner/install_actions.sh \
  && chown runner /_work /actions-runner /opt/hostedtoolcache

COPY token.sh entrypoint.sh app_token.sh /
RUN chmod +x /token.sh /entrypoint.sh /app_token.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]
