# n8n Custom Nodes Integration Guide

## Overview

This guide explains how to integrate custom nodes from `n8n-nodes-starter` into your `n8n-heroku-personal` deployment on Heroku.

## Solution Architecture

### How It Works

1. **Build Process**: The `build-and-deploy.sh` script builds your custom nodes and copies them into the Docker build context
2. **Docker Integration**: The Dockerfile copies the custom nodes source code into the container and builds them during the Docker build process
3. **Node Discovery**: The `N8N_CUSTOM_EXTENSIONS` environment variable tells n8n where to find your custom nodes
4. **Heroku Deployment**: When you push to Heroku, it builds the Docker image with your custom nodes included

### File Structure

```
n8n-heroku-personal/
├── Dockerfile              # Modified to include custom nodes
├── entrypoint.sh           # Modified to set N8N_CUSTOM_EXTENSIONS
├── build-and-deploy.sh     # Automated build and deployment script
├── .dockerignore          # Optimized for custom nodes
├── heroku.yml             # Heroku configuration
└── README.md              # Updated documentation

n8n-nodes-starter/
├── nodes/                 # Your custom nodes
├── credentials/           # Custom credentials
├── dist/                  # Built output
└── package.json           # Node package configuration
```

## Key Changes Made

### 1. Dockerfile (`n8n-heroku-personal/Dockerfile`)

```dockerfile
FROM n8nio/n8n:latest

USER root

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Create directory for custom nodes
RUN mkdir -p /home/node/.n8n/custom

# Copy custom nodes source
COPY ./n8n-nodes-starter /home/node/.n8n/custom/n8n-nodes-starter

# Build and install the custom nodes
WORKDIR /home/node/.n8n/custom/n8n-nodes-starter
RUN pnpm install --force
RUN pnpm run build

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
```

### 2. Entrypoint Script (`n8n-heroku-personal/entrypoint.sh`)

Added the custom extensions path:
```bash
# Set custom nodes path
export N8N_CUSTOM_EXTENSIONS="/home/node/.n8n/custom"
```

### 3. Build Script (`n8n-heroku-personal/build-and-deploy.sh`)

Automated the entire process:
- Builds custom nodes
- Copies them to build context
- Deploys to Heroku
- Cleans up temporary files

## Deployment Instructions

### Quick Deployment

```bash
cd n8n-heroku-personal
./build-and-deploy.sh
```

### Manual Deployment

1. **Build custom nodes:**
   ```bash
   cd n8n-nodes-starter
   pnpm install
   pnpm run build
   ```

2. **Prepare deployment:**
   ```bash
   cd ../n8n-heroku-personal
   rm -rf ./n8n-nodes-starter
   cp -r ../n8n-nodes-starter ./n8n-nodes-starter
   ```

3. **Deploy to Heroku:**
   ```bash
   git add .
   git commit -m "Deploy with custom nodes"
   git push heroku main
   ```

4. **Clean up:**
   ```bash
   rm -rf ./n8n-nodes-starter
   ```

### Local Testing

To test locally before deploying:

```bash
cd n8n-heroku-personal
# Copy nodes to build context
rm -rf ./n8n-nodes-starter
cp -r ../n8n-nodes-starter ./n8n-nodes-starter

# Build Docker image
docker build -t n8n-custom .

# Run locally
docker run --rm -p 5678:5678 -e N8N_ENCRYPTION_KEY="your-test-key" n8n-custom

# Clean up
rm -rf ./n8n-nodes-starter
```

## Environment Variables

Make sure to set these in your Heroku app:

- `N8N_ENCRYPTION_KEY`: A random secure string for encrypting credentials
- `N8N_HOST`: Your Heroku app URL (e.g., `https://your-app.herokuapp.com`)
- `WEBHOOK_URL`: Your Heroku app URL for webhooks

## Custom Nodes Included

After deployment, your n8n instance will include:

- **ExampleNode**: A sample node from n8n-nodes-starter
- **HttpBin**: An HTTP testing node
- Any additional custom nodes you've added to n8n-nodes-starter

## Troubleshooting

### Build Issues

1. **pnpm prompts for confirmation**: Fixed with `--force` flag
2. **TypeScript compilation errors**: Make sure all dependencies are installed
3. **Docker build context errors**: Ensure n8n-nodes-starter is copied to build context

### Runtime Issues

1. **Custom nodes not appearing**: Check `N8N_CUSTOM_EXTENSIONS` environment variable
2. **Permission errors**: Ensure proper ownership is set in Dockerfile
3. **Build failures**: Check Heroku build logs for specific errors

## Adding New Custom Nodes

1. Add your new node to `n8n-nodes-starter/nodes/`
2. Update `n8n-nodes-starter/package.json` to include the new node
3. Test locally in n8n-nodes-starter
4. Run the deployment script

## Security Notes

- The build process switches back to the `node` user for security
- Custom nodes are installed in a dedicated directory
- All file permissions are properly set during build

## Performance Considerations

- Build time increases with the number of custom nodes
- Docker image size increases with custom node dependencies
- Consider using `.dockerignore` to exclude unnecessary files

## Support

- [n8n Custom Nodes Documentation](https://docs.n8n.io/integrations/creating-nodes/)
- [Heroku n8n Tutorial](https://docs.n8n.io/hosting/server-setups/heroku/)
- [n8n Community Forums](https://community.n8n.io/) 