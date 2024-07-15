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

# 2. Install Render CLI
curl -fsSL https://cli-assets.render.com/install.sh | sh

# 3. Create and activate virtual environment
python -m venv venv
source venv/bin/activate

# 4. Install dependencies
pip install -r requirements.txt

# 5. Deploy to Render
render deploy --service $RENDER_PROJECT_ID --token $RENDER_API_KEY

# 6. Success message
echo "Deployment successful!"
