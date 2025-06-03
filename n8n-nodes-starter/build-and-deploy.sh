#!/bin/bash

# Build and Deploy n8n Custom Nodes using pnpm with Docker support

set -e

echo "🔧 Installing dependencies with pnpm..."
pnpm install

echo "🏗️  Building custom nodes..."
pnpm run build

echo "🧪 Running linter..."
pnpm run lint

echo "📁 Listing built files..."
ls -la dist/

echo "✅ Build complete!"
echo ""
echo "📝 Your custom nodes are now built and ready:"
echo "   - ExampleNode"
echo "   - HttpBin" 
echo "   - YouTubeSearch"
echo ""

# Check if we should deploy to Docker/Cloud
read -p "🐳 Do you want to deploy with Docker? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📁 Copying custom nodes to deployment context..."
    
    # Go up to parent directory to work with deployment context
    cd ..
    
    # Remove existing copy if it exists (force removal)
    rm -rf ./custom-nodes-deploy 2>/dev/null || true
    
    # Copy the entire custom-nodes folder to deployment context
    cp -r ./custom-nodes ./custom-nodes-deploy
    
    # Clean up problematic files/folders that might cause Docker build issues
    echo "🧹 Cleaning up copied folder..."
    rm -rf ./custom-nodes-deploy/.git 2>/dev/null || true
    # Use find to remove node_modules more reliably
    find ./custom-nodes-deploy -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
    # Keep the dist folder since we need the built files
    
    echo "🐳 Building Docker image locally..."
    # Check if Dockerfile exists
    if [ -f "Dockerfile" ]; then
        docker build -t n8n-custom-nodes .
        echo "✅ Docker image built successfully!"
        
        read -p "🚀 Deploy to cloud? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "🚀 Deploying to cloud..."
            # Add the copied custom-nodes-deploy to git for deployment
            git add .
            git commit -m "Deploy n8n with custom nodes - $(date)"
            git push
            
            echo "🧹 Cleaning up deployment context..."
            # Remove the copied folder after deployment (force removal)
            git rm -rf ./custom-nodes-deploy
            git commit -m "Clean up custom-nodes-deploy after deployment"
            
            echo "✅ Deployment complete!"
            echo "🌐 Your n8n instance should be available at your cloud app URL"
            echo "📝 Custom nodes should now be available in n8n"
        else
            echo "📦 Docker image ready for manual deployment"
        fi
    else
        echo "⚠️  No Dockerfile found. Please create a Dockerfile for deployment."
        echo "💡 Example Dockerfile structure needed for n8n with custom nodes"
    fi
    
    # Clean up deployment folder if not committed
    if [ -d "./custom-nodes-deploy" ]; then
        rm -rf ./custom-nodes-deploy
    fi
    
    # Return to custom-nodes directory
    cd custom-nodes
else
    echo "🚀 To use these nodes locally:"
    echo "   1. Make sure n8n can find these custom nodes"
    echo "   2. Set N8N_CUSTOM_EXTENSIONS environment variable if needed"
    echo "   3. Restart your n8n instance"
fi

echo ""
echo "💡 For local development:"
echo "   - Run 'pnpm run dev' to watch for changes"
echo "   - Run 'pnpm run format' to format your code" 