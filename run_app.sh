#!/bin/bash
# CIMA Learn App Runner with Environment Variables
# This script sets up environment variables and runs the Flutter web app

# Set environment variables (will use Replit secrets if available)
export SUPABASE_URL="https://pgmtaemwcueobaexthaq.supabase.co"

# Use the Replit secret if available, otherwise use passed value
if [ -n "$SUPABASE_KEY" ]; then
    echo "Using SUPABASE_KEY from environment"
else
    echo "Warning: SUPABASE_KEY not found in environment"
fi

# Clean and prepare Flutter project
echo "Cleaning Flutter project..."
flutter clean

echo "Getting Flutter dependencies..."
flutter pub get --no-precompile

# Analyze the project for issues
echo "Analyzing Flutter project..."
flutter analyze --no-fatal-infos

# Build the Flutter web app with environment variables
echo "Building Flutter web app..."
flutter build web \
    --dart-define=SUPABASE_URL="$SUPABASE_URL" \
    --dart-define=SUPABASE_KEY="$SUPABASE_KEY" \
    --base-href / \
    --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful! Starting server..."
    python3 flutter_server.py
else
    echo "Build failed!"
    exit 1
fi