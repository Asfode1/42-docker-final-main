# ---- Build stage ----
FROM golang:1.22-bookworm AS builder

WORKDIR /app

# Cache dependencies first
COPY go.mod go.sum ./
RUN go mod download

# Copy sources
COPY . .

# Build static binary (no CGO needed for modernc.org/sqlite)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/bin/app ./


# ---- Runtime stage ----
FROM gcr.io/distroless/static-debian12

WORKDIR /app

# Copy binary and the pre-populated SQLite DB with schema
COPY --from=builder /app/bin/app /app/app
COPY --from=builder /app/tracker.db /app/tracker.db

# The app reads/writes tracker.db in the working directory
USER 0:0

CMD ["/app/app"]


