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
          node-version: '18'
      - name: Install Netlify CLI
        run: npm install -g netlify-cli
      - name: Deploy to Netlify
        env:
          NETLIFY_AUTH_TOKEN: \${{ secrets.NETLIFY_AUTH_TOKEN }}
        run: netlify deploy --prod --dir=public # Adjust the directory as needed
EOL
echo "GitHub Actions workflow file created successfully."
# Add the files to staging
git add create_workflow.sh runtime.txt .github/workflows/deploy.yml
# Commit the changes
git commit -m "Add GitHub Actions workflow for Netlify deployment and update runtime.txt"
# Set the remote URL with PAT
git remote set-url origin https://azmusgb:@github.com/azmusgb/ImageConversion.git
# Push the changes
git push origin main
echo "Workflow file pushed to GitHub."
