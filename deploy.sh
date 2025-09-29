#!/bin/bash

# BitZed Local Deployment Script
# This script builds, tests, and pushes to GitHub

set -e

echo "🚀 Starting BitZed deployment process..."

# Step 1: Build and test locally
echo "🔨 Building Flutter app..."
flutter build apk --release
flutter build web --release

# Step 2: Run tests
echo "🧪 Running tests..."
flutter test

# Step 3: Commit and push to GitHub
echo "📤 Pushing to GitHub..."
git add .
git commit -m "Deploy BitZed v2025.09.29"
git push origin main

echo "✅ Deployment process completed!"
echo "🌐 GitHub will automatically deploy to server"
echo "📱 APK will be available at: https://bitzed.xyz/downloads"
