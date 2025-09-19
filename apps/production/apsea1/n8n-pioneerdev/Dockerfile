FROM n8nio/n8n:1.19.4

# Switch to root to install packages
USER root

# Install PostgreSQL client and other utilities
RUN apk add --no-cache postgresql-client curl

# Create n8n config directory and set proper permissions
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n && \
    chmod -R 755 /home/node/.n8n



# Switch back to node user
USER node

# Set working directory
WORKDIR /home/node

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:5678/healthz || exit 1

# Expose port
EXPOSE 5678

# Use the original CMD from the base image