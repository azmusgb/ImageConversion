#!/bin/bash

# Variables
GITHUB_REPO_URL="https://github.com/azmusgb/ImageConversion.git"
NETLIFY_SITE_ID="a3b5bb87-099a-46d2-aed3-f50ed90fbc96"
NETLIFY_AUTH_TOKEN="nfp_ECRqBAZpanYVEp9tBy7PU3r2oBNo4tMod100"

# Initialize a new git repository
git init

# Add the remote GitHub repository
git remote add origin $GITHUB_REPO_URL 2>/dev/null

# Add all files to the repository
git add .

# Commit the changes
git commit -m "Deploy from Replit"

# Push the changes to the GitHub repository
git push -u origin main -f

# Check if npm is installed
if ! command -v npm &> /dev/null
then
    echo "npm not found. Please add Node.js to your Replit environment."
    exit 1
fi

# Install Netlify CLI if not already installed
npm install -g netlify-cli

# Deploy to Netlify
export NETLIFY_AUTH_TOKEN=$NETLIFY_AUTH_TOKEN
netlify deploy --prod --dir=. --site=$NETLIFY_SITE_ID