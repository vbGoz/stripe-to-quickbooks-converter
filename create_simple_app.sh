#!/bin/bash

echo "🎯 Creating a WORKING Mac App with GUI..."
echo "This will create a functioning app that you can double-click to run!"

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

# Create a shell script that launches our GUI
cat > "${APP_BUNDLE}/Contents/MacOS/StripeConverter" << 'EOF'
#!/bin/bash

# Get the directory where this app is located
APP_DIR="$(dirname "$0")/../.."
cd "$APP_DIR"

# Create a simple AppleScript GUI
osascript << 'APPLESCRIPT'
-- Stripe to QuickBooks Converter GUI
set inputFile to ""
set generateReport to true

-- Main dialog
display dialog "Stripe to QuickBooks Converter

Convert your Stripe payout CSV files to QuickBooks format with automatic fee accounting.

Click 'Select File' to choose your Stripe CSV file." buttons {"Quit", "Select File"} default button "Select File" with title "Stripe to QuickBooks Converter"

if button returned of result is "Select File" then
    -- File selection dialog
    try
        set inputFile to (choose file with prompt "Select your Stripe payout CSV file:" of type {"csv", "txt"}) as string
        set inputFile to POSIX path of inputFile
        
        -- Options dialog
        display dialog "File selected: " & (name of (info for (inputFile as POSIX file))) & "

Options:" buttons {"Cancel", "Convert"} default button "Convert" with title "Conversion Options"
        
        if button returned of result is "Convert" then
            -- Show progress
            display notification "Converting Stripe CSV to QuickBooks format..." with title "Stripe Converter"
            
            -- Run the conversion using our command line tool
            set command to "cd '" & (do shell script "dirname " & quoted form of inputFile) & "' && '" & (POSIX path of (path to me)) & "/../stripe_converter' '" & inputFile & "' -r -v"
            
            try
                set result to do shell script command
                
                -- Success dialog
                display dialog "✅ Conversion Completed Successfully!

" & result buttons {"Open Output Folder", "OK"} default button "Open Output Folder" with title "Success!"
                
                if button returned of result is "Open Output Folder" then
                    do shell script "open '" & (do shell script "dirname " & quoted form of inputFile) & "'"
                end if
                
            on error errorMessage
                -- Error dialog
                display dialog "❌ Conversion Failed

Error: " & errorMessage buttons {"OK"} default button "OK" with icon stop with title "Error"
            end try
        end if
        
    on error
        -- User cancelled file selection
        return
    end try
end if
APPLESCRIPT

EOF

# Make the script executable
chmod +x "${APP_BUNDLE}/Contents/MacOS/StripeConverter"

# Copy our command line converter into the app bundle
cp "stripe_converter" "${APP_BUNDLE}/Contents/MacOS/" 2>/dev/null || echo "Note: stripe_converter not found, will be created"

# If stripe_converter doesn't exist, compile it
if [ ! -f "stripe_converter" ]; then
    echo "📦 Compiling command line converter..."
    swiftc stripe_converter.swift -o stripe_converter
    cp "stripe_converter" "${APP_BUNDLE}/Contents/MacOS/"
fi

echo ""
echo "✅ SUCCESS! Mac app created: '${APP_BUNDLE}'"
echo ""
echo "🚀 To use your app:"
echo "   1. Double-click '${APP_BUNDLE}' in Finder"
echo "   2. Click 'Select File' and choose your Stripe CSV"
echo "   3. Click 'Convert' to process the file"
echo "   4. Click 'Open Output Folder' to see your QuickBooks CSV"
echo ""
echo "📱 Features:"
echo "   • Native macOS interface using AppleScript"
echo "   • File picker dialog"
echo "   • Progress notifications"
echo "   • Automatic fee accounting"
echo "   • Summary reports"
echo "   • One-click folder opening"
echo ""

# Test if we can launch it
echo "🎯 Testing the app..."
if [ -f "${APP_BUNDLE}/Contents/MacOS/StripeConverter" ]; then
    echo "   App is ready to launch!"
    echo "   Running: open '${APP_BUNDLE}'"
    open "${APP_BUNDLE}"
else
    echo "   ❌ App creation failed"
fi