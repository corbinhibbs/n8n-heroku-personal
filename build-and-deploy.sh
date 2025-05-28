#!/bin/bash

# Build and Deploy n8n with Custom Nodes to Heroku

set -e

echo "🔧 Building custom nodes..."
cd ../n8n-nodes-starter
pnpm install
pnpm run build
cd ../n8n-heroku-personal

echo "📁 Copying custom nodes to build context..."
# Remove existing copy if it exists
rm -rf ./n8n-nodes-starter
# Copy the entire n8n-nodes-starter folder into the build context
cp -r ../n8n-nodes-starter ./n8n-nodes-starter

echo "🐳 Building Docker image locally (optional test)..."
# Uncomment the next line if you want to test locally first
docker build -t n8n-custom .

echo "🧹 Cleaning up build context..."
# Remove the copied folder to keep the repo clean
rm -rf ./n8n-nodes-starter

# echo "🚀 Deploying to Heroku..."
# git add .
# git commit -m "Deploy n8n with custom nodes - $(date)"
# git push

# echo "✅ Deployment complete!"
# echo "🌐 Your n8n instance should be available at your Heroku app URL"
# echo "📝 Custom nodes from n8n-nodes-starter should now be available in n8n" 