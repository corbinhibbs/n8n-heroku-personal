FROM n8nio/n8n:latest

USER root

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Create directory for custom nodes
RUN mkdir -p /home/node/.n8n/custom

# Copy custom nodes source (assuming it's copied into the build context)
COPY ./n8n-nodes-starter /home/node/.n8n/custom/n8n-nodes-starter

# Build and install the custom nodes
WORKDIR /home/node/.n8n/custom/n8n-nodes-starter
# Install all dependencies including dev dependencies for building (force to skip prompts)
RUN pnpm install --force
# Build using pnpm
RUN pnpm run build

# Install the package globally so n8n can find it
WORKDIR /home/node/.n8n/custom
RUN pnpm install ./n8n-nodes-starter

# Set proper ownership
RUN chown -R node:node /home/node/.n8n

# Switch back to node user for security
USER node

WORKDIR /home/node/packages/cli
ENTRYPOINT []

COPY ./entrypoint.sh /
USER root
RUN chmod +x /entrypoint.sh
USER node
CMD ["/entrypoint.sh"]