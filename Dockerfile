FROM golang:1.22.0-alpine3.19 AS build

# Git is required for fetching the dependencies.
RUN apk update && apk add --no-cache --update git curl nodejs npm bash

# Create work directory
WORKDIR /cactus

# Copying all the files
COPY . .

# Install Go Dependencies
COPY go.mod go.sum ./
RUN go mod download

# Install NPM Dependencies
RUN npm install

# Generate SQLC go files
RUN go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
RUN sqlc generate

# Generate Temple go files
RUN go install github.com/a-h/templ/cmd/templ@latest
RUN templ generate

# Generate Tailwind CSS
RUN npm run tailwind-build

# Install Dependencies
RUN npm install

RUN go build -o /cactus/main cmd/main.go
RUN chmod +x /cactus/main

CMD /cactus/main
EXPOSE 8080