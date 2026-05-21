#!/bin/bash
set -e

# Install Flutter (skip if cached)
if [ ! -d "flutter_sdk" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter_sdk
fi

export PATH="$PATH:$(pwd)/flutter_sdk/bin"

# Build Flutter web
flutter precache --web
flutter build web --release
