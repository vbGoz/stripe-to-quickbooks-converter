#!/bin/bash

echo "🎯 Creating SIMPLIFIED Mac App..."
echo "Removing options dialog - just convert directly after file selection."

# Create the app bundle
APP_NAME="Stripe to QuickBooks Converter"
APP_BUNDLE="${APP_NAME}.app"

rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Create the Info.plist
cat > "${APP_BUNDLE}/Contents/Info.plist" << 'EOF'
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
    <key>CFBundleDisplayName</key>
    <string>Stripe to QuickBooks Converter</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.finance</string>
</dict>
</plist>
EOF

# Create a simple, streamlined script that just converts
cat > "${APP_BUNDLE}/Contents/MacOS/StripeConverter" << 'EOF'
#!/bin/bash

# Get the directory where this app is located
APP_DIR="$(dirname "$0")/../.."
cd "$APP_DIR"

# Create a simple AppleScript GUI - select file, convert, done
osascript << 'APPLESCRIPT'
-- Stripe to QuickBooks Converter GUI
set inputFile to ""

-- Main dialog
display dialog "Stripe to QuickBooks Converter

Convert your Stripe payout CSV files to QuickBooks format with automatic fee accounting.

• Separates transaction fees from income
• Creates QuickBooks-ready CSV format
• Ready to import directly into QuickBooks

Click 'Select File' to choose your Stripe CSV file." buttons {"Quit", "Select File"} default button "Select File" with title "Stripe to QuickBooks Converter"

if button returned of result is "Select File" then
    -- File selection dialog
    try
        set inputFile to (choose file with prompt "Select your Stripe payout CSV file:" of type {"csv", "txt"}) as string
        set inputFile to POSIX path of inputFile
        
        -- Show progress immediately after file selection
        display notification "Converting Stripe CSV to QuickBooks format..." with title "Stripe Converter"
        
        -- Run the conversion
        set command to "cd '" & (do shell script "dirname " & quoted form of inputFile) & "' && '" & (POSIX path of (path to me)) & "/../stripe_converter' '" & inputFile & "' -v"
        
        try
            set result to do shell script command
            
            -- Success dialog
            display dialog "✅ Conversion Completed Successfully!

Your Stripe transactions have been converted to QuickBooks format with fees properly separated.

The QuickBooks CSV file is ready to import.

" & result buttons {"Open Output Folder", "OK"} default button "Open Output Folder" with title "Success!"
            
            if button returned of result is "Open Output Folder" then
                do shell script "open '" & (do shell script "dirname " & quoted form of inputFile) & "'"
            end if
            
        on error errorMessage
            -- Error dialog
            display dialog "❌ Conversion Failed

Error: " & errorMessage & "

Make sure your file is a valid Stripe CSV export." buttons {"OK"} default button "OK" with icon stop with title "Error"
        end try
        
    on error
        -- User cancelled file selection
        return
    end try
end if
APPLESCRIPT

EOF

# Make the script executable
chmod +x "${APP_BUNDLE}/Contents/MacOS/StripeConverter"

# Copy our converter into the app bundle
cp "stripe_converter" "${APP_BUNDLE}/Contents/MacOS/" 2>/dev/null || echo "Note: stripe_converter not found, will be created"

# Make sure we have the improved converter
if [ ! -f "${APP_BUNDLE}/Contents/MacOS/stripe_converter" ]; then
    echo "📦 Adding improved converter..."
    cp "stripe_converter_v2" "stripe_converter" 2>/dev/null || echo "Using existing converter"
    cp "stripe_converter" "${APP_BUNDLE}/Contents/MacOS/"
fi

echo ""
echo "✅ SIMPLIFIED Mac app created: '${APP_BUNDLE}'"
echo ""
echo "🚀 Streamlined workflow:"
echo "   1. Double-click app"
echo "   2. Select Stripe CSV file"
echo "   3. Conversion happens automatically"
echo "   4. Click 'Open Output Folder' to see QuickBooks CSV"
echo ""
echo "💡 No more options screens - just simple, direct conversion!"
echo ""

# Test launch
echo "🎯 Launching simplified app..."
open "${APP_BUNDLE}"