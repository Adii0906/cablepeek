#!/bin/zsh
set -e
cd "${0:h}"
A=CablePeek.app/Contents; mkdir -p $A/MacOS
cat > $A/Info.plist <<'P'
<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>ch.diegobrugger.cablepeek</string>
<key>CFBundleName</key><string>CablePeek</string><key>CFBundleExecutable</key><string>CablePeek</string>
<key>CFBundlePackageType</key><string>APPL</string><key>CFBundleShortVersionString</key><string>0.4</string>
<key>LSMinimumSystemVersion</key><string>14.0</string><key>CFBundleIconFile</key><string>AppIcon</string><key>NSHumanReadableCopyright</key><string>CablePeek</string><key>LSUIElement</key><true/></dict></plist>
P
mkdir -p $A/Resources; cp AppIcon.icns $A/Resources/
swiftc -O -swift-version 5 -parse-as-library -target arm64-apple-macos14.0 Sources/*.swift -o $A/MacOS/CablePeek
codesign --force --sign - CablePeek.app
