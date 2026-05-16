#!/bin/bash

echo "🔨 Building Stripe to QuickBooks Converter Mac App..."

# Create the app bundle structure
APP_NAME="Stripe to QuickBooks Converter"
APP_DIR="${APP_NAME}.app"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

# Create Info.plist
cat > "${APP_DIR}/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>StripeConverter</string>
    <key>CFBundleIdentifier</key>
    <string>com.stripe.quickbooks.converter</string>
    <key>CFBundleName</key>
    <string>Stripe to QuickBooks Converter</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleDisplayName</key>
    <string>Stripe to QuickBooks Converter</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.finance</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>csv</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>CSV File</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSTypeIsPackage</key>
            <false/>
        </dict>
    </array>
</dict>
</plist>
EOF

echo "📁 App bundle structure created"

# Compile the SwiftUI app
echo "🔧 Compiling SwiftUI application..."
swiftc -target arm64-apple-macos14.0 \
       -import-objc-header <(echo) \
       -o "${APP_DIR}/Contents/MacOS/StripeConverter" \
       StripeToQuickBooksGUI.swift

if [ $? -eq 0 ]; then
    echo "✅ App compiled successfully!"
    echo "📱 App created: ${APP_DIR}"
    echo ""
    echo "🚀 To run the app:"
    echo "   Double-click '${APP_DIR}' in Finder"
    echo "   OR run: open '${APP_DIR}'"
    echo ""
    echo "📋 App Features:"
    echo "• Beautiful native macOS interface"
    echo "• File picker for CSV selection"
    echo "• Automatic fee accounting"
    echo "• Progress indicators"
    echo "• Summary reports"
    echo "• Open output folder functionality"
    
    # Make the app executable
    chmod +x "${APP_DIR}/Contents/MacOS/StripeConverter"
    
    # Test launch the app
    echo ""
    echo "🎯 Launching the app now..."
    open "${APP_DIR}"
    
else
    echo "❌ Compilation failed. Let me try a different approach..."
    
    # Try without target specification
    echo "🔧 Trying simpler compilation..."
    swiftc -o "${APP_DIR}/Contents/MacOS/StripeConverter" StripeToQuickBooksGUI.swift
    
    if [ $? -eq 0 ]; then
        chmod +x "${APP_DIR}/Contents/MacOS/StripeConverter"
        echo "✅ App compiled with fallback method!"
        echo "🚀 Launching: open '${APP_DIR}'"
        open "${APP_DIR}"
    else
        echo "❌ Both compilation methods failed"
        echo "💡 You can still use the command line version:"
        echo "   ./stripe_converter sample_stripe_data.csv -r -v"
    fi
fi