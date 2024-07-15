#!/bin/bash

# Step 1: Initialize a new git repository or reinitialize an existing one
git init
git remote remove origin
git remote add origin https://azmusgb:${GITHUB_TOKEN}@github.com/azmusgb/ImageConversion.git

# Step 2: Update .replit file
cat <<EOT > .replit
entrypoint = "app.py"
modules = ["python-3.8", "nodejs-16_x"]

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

# Step 3: Update replit.nix file
cat <<EOT > replit.nix
{ pkgs }: {
  deps = [
    pkgs.python38Full
    pkgs.python38Packages.flask
    pkgs.python38Packages.pillow
    pkgs.python38Packages.sqlalchemy
    pkgs.python38Packages.flask_sqlalchemy
    pkgs.nodejs-16_x  # Correct Node.js version
  ];
}
EOT

# Step 4: Update netlify.toml file
cat <<EOT > netlify.toml
[build]
  publish = "templates"
  command = "source venv/bin/activate && pip install -r requirements.txt && python app.py"

[context.production.environment]
  NETLIFY_AUTH_TOKEN = "${NETLIFY_AUTH_TOKEN}"

[build.environment]
  PYTHON_VERSION = "3.8"

[functions]
  directory = "netlify/functions"

[settings]
  python = "3.8"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
EOT

# Step 5: Create and activate the Python virtual environment
python3.8 -m venv venv
source venv/bin/activate

# Step 6: Install dependencies within the virtual environment
pip install -r requirements.txt

# Step 7: Add all changes to git and commit
git add .
git commit -m "Deploy from Replit and update configuration files"

# Step 8: Push to the repository
git push -u origin main --force

# Step 9: Ensure Node.js and npm are available
# Skipping the apt-get part, using nvm to install nodejs instead
if ! command -v npm &> /dev/null; then
    echo "npm not found, installing..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    nvm install 16
fi

# Step 10: Ensure Netlify CLI is installed
if ! command -v netlify &> /dev/null; then
    echo "Netlify CLI not found, installing..."
    npm install -g netlify-cli
fi

# Step 11: Deploy to Netlify
export NETLIFY_AUTH_TOKEN=${NETLIFY_AUTH_TOKEN}
netlify deploy --prod --dir=. --site=a3b5bb87-099a-46d2-aed3-f50ed90fbc96

# Deactivate virtual environment
deactivate