FROM debian:bookworm as build-cell-viz

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y \
    && apt install -y --no-install-recommends software-properties-common curl git ca-certificates gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt update \
    && apt install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

RUN git clone "https://github.com/jadorno/htm-cell-viz.git" \
    && cd /usr/src/htm-cell-viz \
    && npm install \
    && NODE_OPTIONS=--openssl-legacy-provider npm run build

FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y \
    && apt install -y --no-install-recommends software-properties-common curl git ca-certificates gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt update \
    && apt install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY package.json .
RUN npm install

COPY . .
COPY --from=build-cell-viz /usr/src/htm-cell-viz/dist/cell-viz-3d-1.4.9.min.js /usr/src/app/static/js/third/cell-viz-3d-1.4.9.min.js

CMD ["/usr/bin/npm", "start"]