# Use a minimal Go image to build the application
FROM golang:1.24.1-alpine AS build

# Set the current working directory inside the container
WORKDIR /app

# Copy the Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod tidy

# Copy the rest of the application code
COPY . .

# Build the Go application
RUN go build -o aleo_exporter .

# Use a minimal Alpine image for the final image
FROM alpine:3.18

# Install necessary dependencies (if any) for your app
RUN apk --no-cache add ca-certificates

# Set the working directory in the container
WORKDIR /root/

# Copy the compiled binary from the build stage
COPY --from=build /app/aleo_exporter .

# Expose any ports needed (e.g., the port your exporter listens to)
EXPOSE 9100

# Run the application when the container starts
CMD ["./aleo_exporter"]
