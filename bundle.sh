#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
APP_BUNDLE="$DIR/DropShelf.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "🔨 Building DropShelf Universal Release binary (Apple Silicon + Intel)..."
cd "$DIR"

swift build -c release --triple arm64-apple-macosx13.0
swift build -c release --triple x86_64-apple-macosx13.0

mkdir -p "$DIR/.build/universal"
lipo -create -output "$DIR/.build/universal/DropShelf" \
    "$DIR/.build/arm64-apple-macosx/release/DropShelf" \
    "$DIR/.build/x86_64-apple-macosx/release/DropShelf"

echo "📦 Packaging DropShelf.app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

cp "$DIR/.build/universal/DropShelf" "$MACOS/DropShelf"
if [ -f "$DIR/AppIcon.icns" ]; then
    cp "$DIR/AppIcon.icns" "$RESOURCES/AppIcon.icns"
fi

cat << 'EOF' > "$CONTENTS/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>DropShelf</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.dropshelf.macos</string>
    <key>CFBundleName</key>
    <string>DropShelf</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

chmod +x "$MACOS/DropShelf"
rm -f "$DIR/DropShelf_universal"

echo "📦 Creating downloadable DropShelf-v1.0.0-macOS.zip..."
rm -f "$DIR/DropShelf-v1.0.0-macOS.zip"
ditto -c -k --keepParent "$APP_BUNDLE" "$DIR/DropShelf-v1.0.0-macOS.zip"

echo "✅ DropShelf.app and DropShelf-v1.0.0-macOS.zip created successfully!"
