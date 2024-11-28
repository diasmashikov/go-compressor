# Build stage
FROM golang:1.23-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    pkgconfig

WORKDIR /app

# Copy go.mod and go.sum files from src
COPY ../src/go.mod ../src/go.sum ./

# Download dependencies
RUN go mod download

# Copy all source code from src
COPY ../src ./

# Build the application
RUN go build -o main .

# Final stage
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache \
    pngquant

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /app/main .

# Expose port
EXPOSE 8080

# Run the application
CMD ["./main"]
