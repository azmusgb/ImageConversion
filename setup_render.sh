#!/bin/bash

# Ensure environment variables are set
if [ -z "$RENDER_API_KEY" ]; then
  echo "Error: RENDER_API_KEY is not set."
  exit 1
fi

# 1. Set Environment Variables
RENDER_API_KEY=$RENDER_API_KEY
RENDER_PROJECT_ID="srv-cqae88tds78s739qgpjg"
BUILD_DIR="."

# 2. Install Vercel CLI (if not already installed)
npm install -g vercel

# 3. Build your Flask app
# Assuming you have a build script or steps
pip install -r requirements.txt

# 4. Deploy to Render
curl -fsSL https://cli-assets.render.com/install.sh | sh
render deploy --service $RENDER_PROJECT_ID --token $RENDER_API_KEY

# 5. Clean up the build directory (optional)
# rm -rf $BUILD_DIR

# 6. Success message
echo "Deployment successful!"
