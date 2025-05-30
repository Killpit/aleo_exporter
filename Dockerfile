FROM golang:1.13 AS build

WORKDIR /src 

COPY go.mod go.sum ./

RUN go mod tidy && go mod download

COPY . .

RUN go build -ldflags="-s -w" -o aleo_exporter cmd/aleo_exporter/exporter.go

FROM alpine:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd --no-create-home --shell /bin/false appuser

WORKDIR /app

COPY --from=build /src/aleo_exporter .

USER appuser

EXPOSE 9100

HEALTHCHECK CMD curl --fail http://localhost:9100/health || exit 1

CMD ["./aleo_exporter"]
