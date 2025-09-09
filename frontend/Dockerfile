# Stage 1: Build Stage
FROM node:16-alpine3.16 AS builder
WORKDIR /app
COPY . . 
ENV VUE_APP_API_URL=/
ENV NODE_ENV=/
RUN npx update-browserslist-db@latest
RUN npm ci --include=dev
RUN npm run build

# Stage 2: Production Stage
FROM nginx:1.25.1
WORKDIR /usr/share/app
COPY --from=builder /app/dist/ /usr/share/app
# in local docker compose use nginx.conf
# in remote docker compose again need to copy it
COPY --from=builder /app/nginx.conf /etc/nginx/conf.d/default.conf
