#!/bin/bash

# Create the necessary directories if they do not exist
mkdir -p .github/workflows

# Create the GitHub Actions workflow file
cat <<EOL > .github/workflows/deploy.yml
name: Deploy to Netlify

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.9

      - name: Install dependencies
        run: |
          python -m venv venv
          source venv/bin/activate
          pip install -r requirements.txt

      - name: Run tests
        run: |
          source venv/bin/activate
          pytest

      - name: Set up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '16'

      - name: Install Netlify CLI
        run: npm install -g netlify-cli

      - name: Deploy to Netlify
        env:
          NETLIFY_AUTH_TOKEN: \${{ secrets.NETLIFY_AUTH_TOKEN }}
        run: netlify deploy --prod --dir=public # Adjust the directory as needed
EOL

echo "GitHub Actions workflow file created successfully."

# Add and commit the changes
git add .github/workflows/deploy.yml
git commit -m "Add GitHub Actions workflow for Netlify deployment"

# Update remote URL to include PAT
git remote set-url origin https://YOUR_USERNAME:YOUR_TOKEN@github.com/azmusgb/ImageConversion.git

# Push the changes
git push origin main

echo "Workflow file pushed to GitHub."