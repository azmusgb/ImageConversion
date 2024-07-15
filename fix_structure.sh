#!/bin/bash

# Ensure SSH directory exists
mkdir -p ~/.ssh

# Copy SSH key files to the appropriate location
cp .ssh/id_rsa ~/.ssh/id_rsa
cp .ssh/id_rsa.pub ~/.ssh/id_rsa.pub

# Set appropriate permissions for SSH keys
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Start the SSH agent
eval "$(ssh-agent -s)"

# Add SSH private key to the agent
ssh-add ~/.ssh/id_rsa

# Add the Bitbucket host key to known hosts to prevent confirmation prompt
ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts

# Clean up existing git repository if necessary
rm -rf .git

# Reinitialize the git repository
git init

# Add all files to the repository
git add .

# Commit changes
git commit -m "Clean and reinitialize repo"

# Add the remote repository
git remote add origin git@bitbucket.org:imageconversion/demo.git

# Pull from the remote repository, allowing unrelated histories and keeping your changes
git fetch origin
git pull origin main --allow-unrelated-histories -X theirs

# Automatically resolve conflicts by keeping your changes
find . -name '*.orig' -delete
git add .
git commit -m "Resolve merge conflicts automatically by keeping remote changes"

# Push changes to the remote repository
git push -u origin main --force

echo "Repository successfully synchronized and pushed to remote."