#!/bin/bash

# 1. Set Environment Variables (for security)
VERCEL_TOKEN=$VERCEL_TOKEN  # Access the secret
VERCEL_PROJECT_ID="prj_u4WVVbWTI3PJ5OEUt5w2eez4Dlri"
BUILD_DIR="build"

# 2. Ensure required files are in place

# Create .vercel/project.json
mkdir -p .vercel
cat <<EOT > .vercel/project.json
{
  "projectId": "$VERCEL_PROJECT_ID",
  "orgId": "your-org-id",
  "settings": {
    "framework": "Flask"
  }
}
EOT

# Create runtime.txt
cat <<EOT > runtime.txt
python-3.10
EOT

# Create requirements.txt if it doesn't exist
if [ ! -f requirements.txt ]; then
  cat <<EOT > requirements.txt
blinker==1.8.2
click==8.1.7
Flask==2.0.3
greenlet==3.0.3
itsdangerous==2.2.0
Jinja2==3.1.4
MarkupSafe==2.1.5
pillow==10.4.0
SQLAlchemy==2.0.31
typing_extensions==4.12.12
Werkzeug==3.0.3
EOT
fi

# Create build.sh for building the Flask app
cat <<EOT > build.sh
#!/bin/bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# Add your build commands here (e.g., collect static files)
deactivate
EOT
chmod +x build.sh

# 3. Install n, a Node.js version manager, to manage Node.js versions
curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n
bash n 20.0.0

# 4. Upgrade npm to the latest version
npm install -g npm@latest

# 5. Install Vercel CLI locally within the project
npm install vercel

# 6. Build your Flask app
./build.sh  # Run your build script

# 7. Deploy to Vercel using the locally installed Vercel CLI
npx vercel deploy \
  --prod \
  --token $VERCEL_TOKEN \
  --project $VERCEL_PROJECT_ID \
  --path $BUILD_DIR

# 8. Clean up the build directory (optional)
rm -rf $BUILD_DIR

# 9. Success message
echo "Deployment successful!"