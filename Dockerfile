# ── Stage 1: Build the Flutter web app ───────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copy manifests first to leverage Docker layer caching.
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copy the rest of the source and build.
COPY . .
RUN flutter build web --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://unpkg.com/canvaskit-wasm@0.38.2/bin/

# ── Stage 2: Serve with nginx ─────────────────────────────────────────────────
FROM nginx:1.25-alpine AS runner

LABEL org.opencontainers.image.title="Expense Tracker Web" \
      org.opencontainers.image.description="Flutter expense tracker served via nginx" \
      org.opencontainers.image.source="https://github.com/shahabRDZ/flutter-expense-tracker"

# Remove default nginx static assets.
RUN rm -rf /usr/share/nginx/html/*

# Copy the compiled Flutter web bundle.
COPY --from=builder /app/build/web /usr/share/nginx/html

# Nginx config that supports Flutter's client-side routing (SPA fallback).
RUN printf 'server {\n\
    listen 80;\n\
    server_name _;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
\n\
    # Gzip static assets\n\
    gzip on;\n\
    gzip_types text/plain application/javascript text/css application/json;\n\
\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
\n\
    # Cache control for assets with content hashes\n\
    location ~* \\.(js|css|wasm|png|jpg|jpeg|gif|svg|ico|woff2?)$ {\n\
        expires 1y;\n\
        add_header Cache-Control "public, immutable";\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost/ || exit 1
