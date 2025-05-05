# Build stage
FROM golang:1.13 AS build

WORKDIR /src

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Download Go dependencies
RUN go mod tidy && go mod download

# Copy the entire source code
COPY . .

# Build the Go binary
RUN go build -ldflags="-s -w" -o aleo_exporter .

# Final stage: Create the runtime image
FROM debian:bullseye-slim

# Install necessary packages, including curl for healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Create a non-root user for running the app
RUN useradd --no-create-home --shell /bin/false appuser

# Set the working directory
WORKDIR /app

# Copy the binary from the build stage
COPY --from=build /src/aleo_exporter .

# Ensure the binary is executable
RUN chmod +x /app/aleo_exporter

# Set the user to run the app
USER appuser

# Expose the necessary port
EXPOSE 9100

# Define a healthcheck to ensure the service is running
HEALTHCHECK CMD curl --fail http://localhost:9100/health || exit 1

# Run the application
CMD ["./aleo_exporter"]
