#!/bin/bash

# Build and Deploy n8n with Custom Nodes to Heroku

set -e

echo "🔧 Building custom nodes..."
cd ./n8n-nodes-starter
pnpm install
pnpm run build
cd ..

echo "📁 Copying custom nodes to build context..."
# Remove existing copy if it exists (force removal)
# rm -rf ./n8n-nodes-starter 2>/dev/null || true
# Copy the entire n8n-nodes-starter folder into the build context
# cp -r ../n8n-nodes-starter ./n8n-nodes-starter

# Clean up problematic files/folders that might cause Docker build issues
echo "🧹 Cleaning up copied folder..."
rm -rf ./n8n-nodes-starter/.git 2>/dev/null || true
# Use find to remove node_modules more reliably
find ./n8n-nodes-starter -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
rm -rf ./n8n-nodes-starter/dist 2>/dev/null || true

echo "🐳 Building Docker image locally (optional test)..."
# Uncomment the next line if you want to test locally first
docker build -t n8n-custom .

echo "🚀 Deploying to Heroku..."
# Add the copied n8n-nodes-starter to git for Heroku deployment
git add .
git commit -m "Deploy n8n with custom nodes - $(date)"
git push

echo "🧹 Cleaning up build context..."
# Remove the copied folder after deployment (force removal)
git rm -rf ./n8n-nodes-starter
git commit -m "Clean up n8n-nodes-starter after deployment"

echo "✅ Deployment complete!"
echo "🌐 Your n8n instance should be available at your Heroku app URL"
echo "📝 Custom nodes from n8n-nodes-starter should now be available in n8n" 