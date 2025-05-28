#!/bin/bash

# Prepare n8n with Custom Nodes for Heroku Deployment

set -e

echo "🔧 Building custom nodes..."
cd ../n8n-nodes-starter
pnpm install
pnpm run build
cd ../n8n-heroku-personal

echo "📁 Copying custom nodes to build context..."
# Remove existing copy if it exists (force removal)
rm -rf ./n8n-nodes-starter 2>/dev/null || true
# Copy the entire n8n-nodes-starter folder into the build context
cp -r ../n8n-nodes-starter ./n8n-nodes-starter

# Clean up problematic files/folders that might cause Docker build issues
echo "🧹 Cleaning up copied folder..."
rm -rf ./n8n-nodes-starter/.git 2>/dev/null || true
# Use find to remove node_modules more reliably
find ./n8n-nodes-starter -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
rm -rf ./n8n-nodes-starter/dist 2>/dev/null || true

echo "🐳 Testing Docker build locally..."
docker build -t n8n-custom .

echo "📦 Committing changes for Heroku deployment..."
git add .
git commit -m "Prepare n8n with custom nodes for Heroku deployment - $(date)"

echo ""
echo "✅ Ready for Heroku deployment!"
echo ""
echo "🚀 To deploy to Heroku, run ONE of these commands:"
echo ""
echo "   Option 1 - If you have Heroku CLI and know your app name:"
echo "   heroku git:remote -a YOUR_HEROKU_APP_NAME"
echo "   git push heroku main"
echo ""
echo "   Option 2 - Direct push to Heroku (replace YOUR_APP_NAME):"
echo "   git push https://git.heroku.com/YOUR_APP_NAME.git main"
echo ""
echo "   Option 3 - Deploy via Heroku Dashboard:"
echo "   - Go to your Heroku app dashboard"
echo "   - Connect to GitHub and deploy this branch"
echo ""
echo "📝 Your custom nodes included:"
echo "   - ExampleNode"
echo "   - HttpBin"
echo "   - YouTubeSearch (with ytsr and transcript support)"
echo ""
echo "🧹 After successful deployment, clean up with:"
echo "   git rm -rf ./n8n-nodes-starter && git commit -m 'Clean up after deployment'" 