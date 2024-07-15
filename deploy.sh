#!/bin/bash

# Initialize a new git repository or reinitialize an existing one
git init
git remote remove origin
git remote add origin https://github.com/azmusgb/ImageConversion.git

# Add all changes to git
git add .
git commit -m "Deploy from Replit"

# Push to the repository
git push -u origin main --force

# Ensure Node.js and npm are available
if ! command -v npm &> /dev/null; then
    echo "npm not found, installing..."
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
    apt-get install -y nodejs
fi

# Ensure Netlify CLI is installed
if ! command -v netlify &> /dev/null; then
    echo "Netlify CLI not found, installing..."
    npm install -g netlify-cli
fi

# Deploy to Netlify
export NETLIFY_AUTH_TOKEN=nfp_ECRqBAZpanYVEp9tBy7PU3r2oBNo4tMod100
netlify deploy --prod --dir=. --site=a3b5bb87-099a-46d2-aed3-f50ed90fbc96