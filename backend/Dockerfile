# Stage 1: Build Stage
FROM golang:1.23.0 AS builder
WORKDIR /app
# copy go.mod go.sum and run go mod download for cache
COPY go.mod go.sum ./
RUN go mod download && go mod verify
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -C cmd/api -a -installsuffix cgo -o main .

# Stage 2: Production Stage
FROM alpine:3.19
RUN apk --no-cache add ca-certificates
# for check livenessProbe in k8s needs curl
RUN apk add curl
WORKDIR /root/
COPY --from=builder /app/cmd/api/main .
EXPOSE 8081
CMD ["./main"]