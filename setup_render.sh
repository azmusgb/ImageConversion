#!/bin/bash

# Step 1: Set up the repository structure
mkdir -p .github/workflows

# Step 2: Create render.yaml
cat <<EOT > render.yaml
services:
  - type: web
    name: imageconversion
    env: python
    plan: free
    buildCommand: pip install -r requirements.txt
    startCommand: gunicorn app:app
EOT

# Step 3: Create GitHub Actions Workflow
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
          python-version: 3.10

      - name: Install dependencies
        run: |
          python -m venv venv
          source venv/bin/activate
          pip install -r requirements.txt

      - name: Deploy to Render
        env:
          RENDER_API_KEY: \${{ secrets.RENDER_API_KEY }}
        run: |
          curl -fsSL https://cli-assets.render.com/install.sh | sh
          render deploy --service <your-service-id>
EOT

# Step 4: Ensure requirements.txt is up-to-date
cat <<EOT > requirements.txt
blinker==1.8.2
click==8.1.7
Flask==2.0.3
greenlet==3.0.3
itsdangerous==2.2.0
Jinja2==3.1.4
MarkupSafe==2.1.5
nodejs==0.1.1
npm==0.1.1
optional-django==0.1.0
packaging==21.4
pillow==10.4.0
SQLAlchemy==2.0.31
typing_extensions==4.12.12
Werkzeug==3.0.3
gunicorn==20.1.0
EOT

# Step 5: Create Procfile
cat <<EOT > Procfile
web: gunicorn app:app
EOT

# Step 6: Update app.py
if ! grep -q "if __name__ == \"__main__\":" app.py; then
  echo -e "\nif __name__ == \"__main__\":\n    app.run(host='0.0.0.0', port=5000)" >> app.py
fi

# Step 7: Git setup
git add .
git commit -m "Configure deployment to Render"
git push origin main

# Step 8: Instructions for GitHub secrets
echo "Ensure to add your Render API key as a secret named 'RENDER_API_KEY' in your GitHub repository settings."

echo "Setup completed. Push your changes to GitHub to start the deployment process."