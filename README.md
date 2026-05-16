# Stripe to QuickBooks Converter

A native macOS application with a beautiful GUI that converts Stripe payout CSV exports to QuickBooks-compatible format with automatic fee accounting.

## Features

- 🖥️ **Native macOS App**: Beautiful SwiftUI interface with drag & drop support
- ✅ Converts Stripe payout CSV data to QuickBooks import format
- 💰 Automatically separates transaction fees from gross amounts
- 📊 Generates detailed summary reports
- 🏷️ Categorizes transactions by type (charges, refunds, payouts, etc.)
- 📝 Includes transaction memos with Stripe IDs for easy tracking
- 🚀 Both GUI and command-line versions available
- 📂 One-click "Open Output Folder" functionality

## How It Works

The converter processes your Stripe payout CSV and creates QuickBooks entries that:

1. **Main Transaction Entry**: Records the gross transaction amount as income
2. **Fee Entry**: Records Stripe processing fees as expenses (negative amounts)
3. **Proper Categorization**: Assigns appropriate categories (Sales Income, Refunds, Payment Processing Fees, etc.)
4. **Account Mapping**: Maps all transactions to a "Stripe" account for easy reconciliation

## Quick Start (GUI App)

### Option 1: Use the Ready-Made App
```bash
./create_simple_app.sh
```
This creates `Stripe to QuickBooks Converter.app` - just double-click it to run!

### Option 2: Build from Source (if you want Xcode)
The Xcode project files had formatting issues, but you can use the working app above or build your own using the Swift files provided.

## How to Use the Mac App

1. **Double-click** `Stripe to QuickBooks Converter.app`
2. **Click "Select File"** and choose your Stripe CSV
3. **Click "Convert"** to process the file  
4. **Click "Open Output Folder"** to find your converted files

## App Features

- **🖱️ Native macOS Interface**: Clean dialogs using AppleScript
- **📂 File Picker**: Browse and select CSV files easily
- **📊 Progress Notifications**: See conversion status in real-time  
- **💰 Automatic Fee Separation**: Creates separate entries for fees
- **📋 Summary Reports**: Detailed breakdown of conversions
- **🗂️ Quick Access**: One-click to open output folder
- **✅ Error Handling**: Clear error messages if something goes wrong

## Quick Start (Command Line)

### Using the Command Line Version

1. **Compile the converter:**
   ```bash
   swiftc stripe_converter.swift -o stripe_converter
   ```

2. **Run the conversion:**
   ```bash
   ./stripe_converter your_stripe_data.csv -r -v
   ```

### Command Line Options

- `-o, --output <file>`: Specify output file path (optional)
- `-r, --report`: Generate a detailed summary report
- `-v, --verbose`: Show detailed processing information

### Example Usage

```bash
# Basic conversion
./stripe_converter stripe_payout_2024.csv

# With custom output file and report
./stripe_converter stripe_payout_2024.csv -o my_quickbooks_data.csv -r -v
```

## Input Format (Stripe CSV)

Your Stripe CSV should contain these columns:
- `id`: Transaction ID
- `created`: Transaction date (YYYY-MM-DD HH:mm:ss)
- `amount`: Transaction amount in cents
- `currency`: Currency code (e.g., "usd")
- `fee`: Stripe fee in cents
- `net`: Net amount in cents
- `type`: Transaction type (charge, refund, payout, etc.)
- `description`: Transaction description
- `source_id`: Source ID (optional)
- `customer_id`: Customer ID (optional)

## Output Format (QuickBooks CSV)

The generated QuickBooks CSV contains:
- `Date`: Transaction date (MM/dd/yyyy format)
- `Description`: Transaction description
- `Amount`: Transaction amount (positive for income, negative for fees)
- `Category`: Assigned category based on transaction type
- `Account`: Always set to "Stripe"
- `Memo`: Additional details including Stripe transaction ID

## Transaction Categories

The converter automatically assigns categories:

- **Sales Income**: Regular charges/payments
- **Refunds**: Customer refunds
- **Payment Processing Fees**: Stripe fees
- **Transfer to Bank**: Payouts to your bank account
- **Adjustments**: Account adjustments
- **Application Fees**: Platform fees
- **Other Income**: Miscellaneous transactions

## Sample Output

For a $50 charge with $1.75 fee, you'll get two QuickBooks entries:

1. **Income Entry**: +$50.00 (Sales Income)
2. **Fee Entry**: -$1.75 (Payment Processing Fees)

This ensures your books show both gross revenue and processing costs separately.

## Project Structure

```
stripe-to-quickbooks-converter/
├── StripeToQuickBooksConverter.xcodeproj/     # Xcode project
├── StripeToQuickBooksConverter/               # macOS app source
│   ├── StripeToQuickBooksConverterApp.swift  # App entry point
│   ├── ContentView.swift                     # Main UI
│   ├── Models.swift                          # Data structures
│   ├── CSVParser.swift                       # CSV parsing logic
│   ├── TransactionConverter.swift            # Conversion logic
│   ├── Supporting Files/                     # Assets & config
│   └── Preview Content/                      # Xcode previews
├── stripe_converter.swift                    # Standalone CLI version
├── sample_stripe_data.csv                   # Sample test data
├── open_xcode.sh                           # Quick Xcode launcher
└── README.md                               # This file
```

## Building from Source

### Native macOS App (Recommended)
1. **Open Xcode project:**
   ```bash
   open StripeToQuickBooksConverter.xcodeproj
   ```
2. **Build and run** (⌘R)
3. **Archive for distribution** (Product → Archive)

### Command Line Version
```bash
swiftc stripe_converter.swift -o stripe_converter
```

## Requirements

- **macOS 14.0+** (for GUI app)
- **Xcode 15.0+** (for building)
- **Swift 5.0+**
- Stripe payout CSV export file

## Importing to QuickBooks

1. **Convert your file** using the app
2. **Open QuickBooks**
3. **Go to Banking → Import Transactions**
4. **Select the generated CSV file**
5. **Map the columns as needed**
6. **Review and import**

## App Screenshots & Usage

The native macOS app provides:
- **Clean, intuitive interface** with drag & drop support
- **Real-time progress indicators** during conversion
- **Detailed conversion results** with transaction counts
- **Summary reports** with financial breakdowns
- **Quick file access** with "Open Output Folder" button
- **Error handling** with clear error messages

## Notes

- The converter handles fees by creating separate negative entries
- All amounts are converted from cents to dollars
- Dates are formatted for QuickBooks compatibility (MM/dd/yyyy)
- Transaction IDs are preserved in memo fields for audit trails
- The app uses macOS sandboxing for security
- Files are processed locally - no data leaves your computer

## Support

For issues or feature requests:
1. **Check the generated files** and ensure your Stripe CSV matches the expected format
2. **Use verbose mode** (-v) in CLI for detailed processing information
3. **Review the summary report** for transaction breakdowns
4. **Verify file permissions** if you encounter file access issues