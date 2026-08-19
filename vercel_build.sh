#!/bin/bash
set -e

echo "Installing Flutter SDK..."
FLUTTER_DIR="$HOME/flutter"
if [ ! -d "$FLUTTER_DIR/.git" ]; then
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_DIR" 2>/dev/null || true
fi

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "ERROR: Flutter SDK not available"
  exit 1
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter config --no-analytics
flutter pub get
flutter build web --release

echo "Flutter web build complete."