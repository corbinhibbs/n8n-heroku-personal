# n8n-heroku with Custom Nodes

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://dashboard.heroku.com/new?template=https://github.com/n8n-io/n8n-heroku/tree/main)

## n8n - Free and open fair-code licensed node based Workflow Automation Tool with Custom Nodes

This is a [Heroku](https://heroku.com/)-focused container implementation of [n8n](https://n8n.io/) that includes custom nodes from the `n8n-nodes-starter` project.

## Features

- 🚀 Deploy n8n to Heroku with one click
- 🔧 Includes custom nodes from `n8n-nodes-starter`
- 🐳 Docker-based deployment
- 🗄️ PostgreSQL database integration
- 🔒 Secure environment variable configuration

## Quick Deploy

Use the **Deploy to Heroku** button above to launch n8n on Heroku. When deploying, make sure to check all configuration options and adjust them to your needs. It's especially important to set `N8N_ENCRYPTION_KEY` to a random secure value.

## Custom Deployment with Your Nodes

1. **Prepare your custom nodes:**
   ```bash
   cd ../n8n-nodes-starter
   npm install
   npm run build
   ```

2. **Deploy using the build script:**
   ```bash
   cd ../n8n-heroku-personal
   ./build-and-deploy.sh
   ```

3. **Manual deployment:**
   ```bash
   git add .
   git commit -m "Deploy with custom nodes"
   git push heroku main
   ```

## What's Included

This deployment automatically includes:
- Custom nodes from the `n8n-nodes-starter` project
- Example nodes (ExampleNode, HttpBin)
- All credentials and node definitions
- Proper build and installation process

## Environment Variables

Make sure to set these important environment variables in Heroku:
- `N8N_ENCRYPTION_KEY`: A random secure string for encrypting credentials
- `N8N_HOST`: Your Heroku app URL
- `WEBHOOK_URL`: Your Heroku app URL for webhooks

## References

- [Heroku n8n tutorial](https://docs.n8n.io/hosting/server-setups/heroku/)
- [n8n Custom Nodes Documentation](https://docs.n8n.io/integrations/creating-nodes/)
- [n8n Community Forums](https://community.n8n.io/)
