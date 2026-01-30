# develop container
FROM node:25.5.0 AS develop

# build container
FROM node:25.5.0 AS build

USER node

COPY --chown=node:node . /app
WORKDIR /app

RUN yarn install
RUN NODE_OPTIONS=--openssl-legacy-provider yarn gulp release

# deploy container
FROM node:25.5.0-slim AS deploy

USER node
WORKDIR /app

# Copy build artifacts
COPY --from=build --chown=node:node /app/wwwroot wwwroot
COPY --from=build --chown=node:node /app/node_modules node_modules
COPY --from=build /app/serverconfig.json serverconfig.json
COPY --from=build /app/index.js index.js
COPY --from=build /app/package.json package.json
COPY --from=build /app/version.js version.js

EXPOSE 3001
ENV NODE_ENV=production

CMD ["node", "./node_modules/terriajs-server/lib/app.js", "--config-file", "serverconfig.json"]
