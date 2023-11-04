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

# Update and install dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    jq \
    git \
    ftp \
    libcurl4 \
    python3 \
    python3-pip \
    python3-setuptools \
    rsync \
    sqlite3 \
    unzip \
    wget \
    zip \
    tar \
    time \
    brotli \
    bison \
    php \
    # Additional packages for Puppeteer and Cypress
    libpangocairo-1.0-0 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxi6 \
    libxtst6 \
    libnss3 \
    libcups2 \
    libxss1 \
    libxrandr2 \
    libgconf-2-4 \
    libasound2 \
    libatk1.0-0 \
    libgtk-3-0

# Download and import the Nodesource GPG key
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key |

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
