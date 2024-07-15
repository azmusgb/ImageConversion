#!/bin/bash

# Initialize a new git repository or reinitialize an existing one
git init
git remote remove origin
git remote add origin https://azmusgb:${GITHUB_TOKEN}@github.com/azmusgb/ImageConversion.git

# Update .replit file
cat <<EOT > .replit
entrypoint = "app.py"
modules = ["python-3.10", "nodejs-20_x"]

[nix]
channel = "stable-23_05"

[unitTest]
language = "python3"

[gitHubImport]
requiredFiles = [".replit", "replit.nix"]

[deployment]
run = ["python3", "app.py"]
deploymentTarget = "cloudrun"

[[ports]]
localPort = 5000
externalPort = 80

[auth]
pageEnabled = true
buttonEnabled = false
EOT

# Update replit.nix file
cat <<EOT > replit.nix
{ pkgs }: {
  deps = [
    pkgs.python310Full
    pkgs.python310Packages.flask
    pkgs.python310Packages.pillow
    pkgs.python310Packages.sqlalchemy
    pkgs.python310Packages.flask_sqlalchemy
    pkgs.nodejs-20_x  # Correct Node.js version
  ];
}
EOT

# Update runtime.txt file
echo "python-3.10" > runtime.txt

# Create and activate the Python virtual environment
python3.10 -m venv venv
source venv/bin/activate

# Install dependencies within the virtual environment
pip install -r requirements.txt

# Add all changes to git and commit
git add .
git commit -m "Deploy from Replit and update configuration files"

# Push to the repository
git push -u origin main --force

# Ensure Node.js and npm are available
if ! command -v npm &> /dev/null; then
    echo "npm not found, installing..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
fi

# Update GitHub Actions workflow file
mkdir -p .github/workflows
cat <<EOT > .github/workflows/deploy.yml
name: Deploy to Render

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

      - name: Deploy to Render
        env:
          RENDER_API_KEY: ${{ secrets.RENDER_API_KEY }}
        run: |
          curl -L https://api.render.com/deploy/srv-cqae88tds78s739qgpjg?key=${{ secrets.RENDER_API_KEY }}
EOT
