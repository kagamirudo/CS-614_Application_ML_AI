#!/bin/bash
# Script to push to GitHub after creating the repository
# Usage: ./push_to_github.sh <your-github-username>

if [ -z "$1" ]; then
    echo "Usage: ./push_to_github.sh <your-github-username>"
    echo ""
    echo "First, create the repository on GitHub:"
    echo "  1. Go to https://github.com/new"
    echo "  2. Repository name: 'CS 614 - Application of ML/AI'"
    echo "  3. Make it private or public (your choice)"
    echo "  4. DO NOT initialize with README, .gitignore, or license"
    echo "  5. Click 'Create repository'"
    echo ""
    echo "Then run this script with your GitHub username"
    exit 1
fi

GITHUB_USER=$1
REPO_NAME="CS-614---Application-of-ML-AI"

echo "Setting up remote repository..."
git remote add origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git" 2>/dev/null || \
git remote set-url origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

echo "Pushing to GitHub..."
git push -u origin main

echo ""
echo "Done! Your repository is now on GitHub:"
echo "https://github.com/${GITHUB_USER}/${REPO_NAME}"
