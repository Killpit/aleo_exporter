# Use a minimal Go image to build the application
FROM golang:1.13 AS build

# Set the current working directory inside the container
WORKDIR /src 

# Copy the Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod tidy
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the Go application
RUN go build -o aleo_exporter .

# Use a Debian-based image for the final image
FROM debian:stable-slim

# Install necessary dependencies (if any) for your app
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /root/

# Copy the compiled binary from the build stage
COPY --from=build /src/aleo_exporter .

# Expose any ports needed (e.g., the port your exporter listens to)
EXPOSE 9100

# Run the application when the container starts
CMD ["./aleo_exporter"]
