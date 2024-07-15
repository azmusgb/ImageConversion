#!/bin/bash
# Step 1: Initialize a new git repository or reinitialize an existing one
git init
git remote remove origin
git remote add origin https://azmusgb:${GITHUB_TOKEN}@github.com/azmusgb/ImageConversion.git
# Step 2: Update .replit file
cat <<EOT > .replit
entrypoint = "app.py"
modules = ["python-3.10", "nodejs-18_x"]  
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
    pkgs.python310Full
    pkgs.python310Packages.flask
    pkgs.python310Packages.pillow
    pkgs.python310Packages.sqlalchemy
    pkgs.python310Packages.flask_sqlalchemy
    pkgs.nodejs-18_x 
  ];
}
EOT
# Step 4: Create runtime.txt to specify Python version
echo "python-3.10" > runtime.txt
# Step 5: Update netlify.toml file
cat <<EOT > netlify.toml
[build]
  publish = "templates"
  command = "source /opt/buildhome/repo/venv/bin/activate && pip install -r requirements.txt && python app.py"
[context.production.environment]
  NETLIFY_AUTH_TOKEN = "${NETLIFY_AUTH_TOKEN}"
[build.environment]
  PYTHON_VERSION = "3.10"
  NODE_VERSION = "18" 
[functions]
  directory = "netlify/functions"
[settings]
  python = "3.10"
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
EOT
# Step 6: Create and activate the Python virtual environment
python3.10 -m venv venv
# Step 7: Install dependencies within the virtual environment
venv/bin/pip install -r requirements.txt
# Step 8:  Install Netlify CLI within the virtual environment
venv/bin/pip install netlify-cli
# Step 9: Add all changes to git and commit
git add .
git commit -m "Deploy from Replit and update configuration files"
# Step 10: Push to the repository
git push -u origin main --force
# Step 11: Deploy to Netlify (ensure the virtual environment is activated)
export NETLIFY_AUTH_TOKEN=${NETLIFY_AUTH_TOKEN}
venv/bin/netlify deploy --prod --dir=. --site=a3b5bb87-099a-46d2-aed3-f50ed90fbc96
