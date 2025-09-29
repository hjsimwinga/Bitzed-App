#!/bin/bash

# Simple server deployment script
# This script pulls from GitHub and deploys

set -e

echo "🚀 Deploying BitZed from GitHub..."

# Navigate to project directory
cd /srv/Bitzed-App

# Pull latest changes
git pull origin main

# Build APK
flutter build apk --release

# Copy to downloads
cp build/app/outputs/flutter-apk/app-release.apk /srv/website/downloads/BitZed-v1.0.0.apk

echo "✅ Server deployment completed!"
