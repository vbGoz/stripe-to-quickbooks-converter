#!/bin/bash

echo "🎯 Creating IMPROVED Mac App with better UX..."
echo "Removing unnecessary options dialog and streamlining the interface."

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

# Create a streamlined script with real options
cat > "${APP_BUNDLE}/Contents/MacOS/StripeConverter" << 'EOF'
#!/bin/bash

# Get the directory where this app is located
APP_DIR="$(dirname "$0")/../.."
cd "$APP_DIR"

# Create an improved AppleScript GUI with actual options
osascript << 'APPLESCRIPT'
-- Stripe to QuickBooks Converter GUI
set inputFile to ""

-- Main dialog
display dialog "Stripe to QuickBooks Converter

Convert your Stripe payout CSV files to QuickBooks format with automatic fee accounting.

• Separates transaction fees from income
• Creates QuickBooks-ready CSV format
• Includes detailed summary reports

Click 'Select File' to choose your Stripe CSV file." buttons {"Quit", "Select File"} default button "Select File" with title "Stripe to QuickBooks Converter"

if button returned of result is "Select File" then
    -- File selection dialog
    try
        set inputFile to (choose file with prompt "Select your Stripe payout CSV file:" of type {"csv", "txt"}) as string
        set inputFile to POSIX path of inputFile
        
        -- Options dialog with actual choices
        set optionsDialog to display dialog "Ready to convert: " & (name of (info for (inputFile as POSIX file))) & "

Choose conversion options:" buttons {"Cancel", "Basic Convert", "Convert + Report"} default button "Convert + Report" with title "Conversion Options"
        
        set conversionChoice to button returned of optionsDialog
        
        if conversionChoice is not "Cancel" then
            -- Show progress
            display notification "Converting Stripe CSV to QuickBooks format..." with title "Stripe Converter"
            
            -- Build command based on user choice
            set baseCommand to "cd '" & (do shell script "dirname " & quoted form of inputFile) & "' && '" & (POSIX path of (path to me)) & "/../stripe_converter' '" & inputFile & "'"
            
            if conversionChoice is "Convert + Report" then
                set command to baseCommand & " -r -v"
            else
                set command to baseCommand & " -v"
            end if
            
            try
                set result to do shell script command
                
                -- Success dialog
                if conversionChoice is "Convert + Report" then
                    set successMessage to "✅ Conversion Completed Successfully!

Your Stripe transactions have been converted to QuickBooks format with fees properly separated.

Files created:
• QuickBooks CSV (ready to import)
• Detailed summary report

" & result
                else
                    set successMessage to "✅ Conversion Completed Successfully!

Your Stripe transactions have been converted to QuickBooks format with fees properly separated.

" & result
                end if
                
                display dialog successMessage buttons {"Open Output Folder", "OK"} default button "Open Output Folder" with title "Success!"
                
                if button returned of result is "Open Output Folder" then
                    do shell script "open '" & (do shell script "dirname " & quoted form of inputFile) & "'"
                end if
                
            on error errorMessage
                -- Error dialog
                display dialog "❌ Conversion Failed

Error: " & errorMessage & "

Make sure your file is a valid Stripe CSV export." buttons {"OK"} default button "OK" with icon stop with title "Error"
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

# Copy our improved command line converter into the app bundle
cp "stripe_converter" "${APP_BUNDLE}/Contents/MacOS/" 2>/dev/null || echo "Note: stripe_converter not found, will be created"

# If stripe_converter doesn't exist, use the improved version
if [ ! -f "stripe_converter" ]; then
    echo "📦 Using improved converter..."
    cp "stripe_converter_v2" "stripe_converter"
    cp "stripe_converter" "${APP_BUNDLE}/Contents/MacOS/"
fi

echo ""
echo "✅ IMPROVED Mac app created: '${APP_BUNDLE}'"
echo ""
echo "🚀 What's new:"
echo "   • Meaningful conversion options:"
echo "     - 'Basic Convert': Just creates QuickBooks CSV"
echo "     - 'Convert + Report': Adds detailed summary report"
echo "   • Better progress messages"
echo "   • Clearer success dialogs"
echo "   • No more empty options screens"
echo ""
echo "💡 To use:"
echo "   1. Double-click '${APP_BUNDLE}'"
echo "   2. Select your Stripe CSV file"
echo "   3. Choose 'Convert + Report' (recommended)"
echo "   4. Click 'Open Output Folder' to see results"
echo ""

# Test launch
echo "🎯 Launching improved app..."
open "${APP_BUNDLE}"