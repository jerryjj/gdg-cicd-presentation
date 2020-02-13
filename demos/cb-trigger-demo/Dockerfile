# Do the npm install or yarn install in the full image
FROM node:11-alpine AS build

WORKDIR /app
ADD src/package*.json ./
RUN npm install --production

# And then copy over node_modules, etc from that stage to the smaller base image
FROM node:11-alpine

WORKDIR /app
COPY --from=build /app .
ADD src/. ./

CMD ["node", "index.js"]
