FROM node:20-bookworm-slim

# Set Python interpreter for `node-gyp` to use
ENV PYTHON=/usr/bin/python3

# Install build dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential libsqlite3-dev git && \
    rm -rf /var/lib/apt/lists/*

USER node
WORKDIR /app

# --- FIX: Copy files and folders selectively to reduce image size ---
# This avoids copying the host's node_modules, .git, and other unnecessary files.
COPY --chown=node:node package.json yarn.lock .yarnrc.yml backstage.json ./
COPY --chown=node:node .yarn ./.yarn
COPY --chown=node:node app-config*.yaml ./
COPY --chown=node:node packages/ ./packages/
COPY --chown=node:node plugins/ ./plugins/
COPY --chown=node:node catalogs/ ./catalogs/

# This disables node snapshot for Node 20 to work with the Scaffolder
ENV NODE_OPTIONS="--no-node-snapshot"

# Install dependencies using the lockfile.
# This will now install a fresh, clean node_modules inside the image,
# which is necessary for the Linux environment.
RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn install --immutable

# The command to run in development
CMD ["yarn", "start"]