FROM node:20-bookworm-slim

# Set Python interpreter for `node-gyp` to use
ENV PYTHON=/usr/bin/python3

# Install isolate-vm dependencies, these are needed by the @backstage/plugin-scaffolder-backend.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install sqlite3 dependencies. You can skip this if you don't use sqlite3 in the image,
# in which case you should also move better-sqlite3 to "devDependencies" in package.json.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends libsqlite3-dev git && \
    rm -rf /var/lib/apt/lists/*

# From here on we use the least-privileged `node` user to run the backend.
USER node

# This should create the app dir as `node`.
# If it is instead created as `root` then the `tar` command below will fail: `can't create directory 'packages/': Permission denied`.
# If this occurs, then ensure BuildKit is enabled (`DOCKER_BUILDKIT=1`) so the app dir is correctly created as `node`.
WORKDIR /app

# Copy configuration and package manifests
COPY --chown=node:node package.json yarn.lock .yarnrc.yml backstage.json ./
COPY --chown=node:node .yarn ./.yarn

# This switches many Node.js dependencies to production mode.
# ENV NODE_ENV=production

# This disables node snapshot for Node 20 to work with the Scaffolder
ENV NODE_OPTIONS="--no-node-snapshot"

# Install dependencies using the lockfile to ensure consistency
RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn install --frozen-lockfile

# This will include the catalogs, if you don't need these simply remove this line
# COPY --chown=node:node catalogs ./catalogs

# Then copy the rest of the backend bundle, along with any other files we might want.
# COPY --chown=node:node packages/backend/dist/bundle.tar.gz app-config*.yaml ./
# RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

# for Production
# CMD ["node", "packages/backend/dist/index.cjs.js", "--config", "app-config.yaml"]

# for Development
CMD ["yarn", "start"]
