import Foundation

// Improved Stripe to QuickBooks converter that handles real Stripe CSV formats

struct StripeTransaction {
    let id: String
    let created: Date
    let amount: Double
    let currency: String
    let fee: Double
    let net: Double
    let type: String
    let description: String
    let sourceId: String?
    let customerId: String?
    let customerEmail: String?
    let customerName: String?
    
    init?(from csvRow: [String: String]) {
        // Handle different CSV formats from Stripe
        // Try the new format first (Type, ID, Created, etc.)
        let id = csvRow["ID"] ?? csvRow["id"] ?? ""
        let createdString = csvRow["Created"] ?? csvRow["created"] ?? ""
        let amountString = csvRow["Amount"] ?? csvRow["amount"] ?? ""
        let feeString = csvRow["Fees"] ?? csvRow["fee"] ?? ""
        let netString = csvRow["Net"] ?? csvRow["net"] ?? ""
        let currency = csvRow["Currency"] ?? csvRow["currency"] ?? ""
        let type = csvRow["Type"] ?? csvRow["type"] ?? ""
        let description = csvRow["Description"] ?? csvRow["description"] ?? ""
        
        guard !id.isEmpty, !createdString.isEmpty, !amountString.isEmpty,
              !currency.isEmpty, !type.isEmpty, !description.isEmpty else {
            return nil
        }
        
        // Try multiple date formats
        let formatter = DateFormatter()
        var created: Date?
        
        // Try format: "2025-08-26 01:41"
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        created = formatter.date(from: createdString)
        
        if created == nil {
            // Try format: "2025-08-26 01:41:30"
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            created = formatter.date(from: createdString)
        }
        
        if created == nil {
            // Try other common formats
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
            created = formatter.date(from: createdString)
        }
        
        guard let validDate = created else {
            print("Failed to parse date: \(createdString)")
            return nil
        }
        
        // Parse amounts - handle both dollars (40.00) and cents (4000)
        guard let amount = Double(amountString) else {
            print("Failed to parse amount: \(amountString)")
            return nil
        }
        
        let fee = Double(feeString) ?? 0.0
        let net = Double(netString) ?? amount - fee
        
        self.id = id
        self.created = validDate
        
        // Detect if amounts are in dollars or cents
        // If amount is > 100 and no decimal point, it's probably cents
        if amount > 100 && !amountString.contains(".") {
            self.amount = amount / 100.0
            self.fee = fee / 100.0
            self.net = net / 100.0
        } else {
            self.amount = amount
            self.fee = fee
            self.net = net
        }
        
        self.currency = currency
        self.type = type
        self.description = description
        self.sourceId = csvRow["source_id"]
        self.customerId = csvRow["Customer ID"] ?? csvRow["customer_id"]
        self.customerEmail = csvRow["Customer Email"] ?? csvRow["customer_email"]
        self.customerName = csvRow["Customer Name"] ?? csvRow["customer_name"]
    }
}

struct QuickBooksTransaction {
    let date: Date
    let description: String
    let amount: Double
    let category: String
    let account: String
    let customerName: String?
    let memo: String?
    
    func toCSVRow() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        return [
            formatter.string(from: date),
            description,
            String(format: "%.2f", amount),
            category,
            account,
            customerName ?? "",
            memo ?? ""
        ]
    }
    
    static var csvHeaders: [String] {
        return ["Date", "Description", "Amount", "Category", "Account", "Customer Name", "Memo"]
    }
}

class CSVParser {
    static func parseStripeCSV(from filePath: String) throws -> [StripeTransaction] {
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        
        // Parse CSV properly handling multi-line quoted fields
        let csvRows = parseCSVContent(content)
        
        guard let headerRow = csvRows.first else {
            throw CSVError.emptyFile
        }
        
        print("CSV Headers found: \(headerRow.joined(separator: ","))")
        let headers = headerRow
        var transactions: [StripeTransaction] = []
        
        print("Processing \(csvRows.count - 1) data rows...")
        
        for (index, row) in csvRows.dropFirst().enumerated() {
            guard row.count == headers.count else { 
                print("Row \(index + 2): Column count mismatch. Expected \(headers.count), got \(row.count)")
                continue 
            }
            
            var rowDict: [String: String] = [:]
            for (headerIndex, header) in headers.enumerated() {
                rowDict[header] = row[headerIndex]
            }
            
            if let transaction = StripeTransaction(from: rowDict) {
                transactions.append(transaction)
                print("✓ Parsed transaction: \(transaction.id) - \(transaction.description) - $\(transaction.amount)")
            } else {
                print("✗ Failed to parse row \(index + 2): \(rowDict)")
            }
        }
        
        print("Successfully parsed \(transactions.count) transactions")
        return transactions
    }
    
    // Improved CSV parser that handles multi-line quoted fields
    private static func parseCSVContent(_ content: String) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var insideQuotes = false
        var i = content.startIndex
        
        while i < content.endIndex {
            let char = content[i]
            
            if char == "\"" {
                if insideQuotes {
                    // Check if this is an escaped quote (double quote)
                    let nextIndex = content.index(after: i)
                    if nextIndex < content.endIndex && content[nextIndex] == "\"" {
                        // Escaped quote, add single quote to field
                        currentField.append("\"")
                        i = nextIndex // Skip the second quote
                    } else {
                        // End of quoted field
                        insideQuotes = false
                    }
                } else {
                    // Start of quoted field
                    insideQuotes = true
                }
            } else if char == "," && !insideQuotes {
                // Field separator
                currentRow.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
                currentField = ""
            } else if (char == "\n" || char == "\r") && !insideQuotes {
                // End of row (only if not inside quotes)
                if !currentField.isEmpty || !currentRow.isEmpty {
                    currentRow.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
                    if !currentRow.isEmpty {
                        rows.append(currentRow)
                    }
                    currentRow = []
                    currentField = ""
                }
            } else {
                // Regular character (including newlines inside quotes)
                currentField.append(char)
            }
            
            i = content.index(after: i)
        }
        
        // Handle last field/row
        if !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
            if !currentRow.isEmpty {
                rows.append(currentRow)
            }
        }
        
        return rows
    }
    
    static func writeQuickBooksCSV(transactions: [QuickBooksTransaction], to filePath: String) throws {
        var csvContent = QuickBooksTransaction.csvHeaders.joined(separator: ",") + "\n"
        
        for transaction in transactions {
            let row = transaction.toCSVRow().map { "\"\($0)\"" }.joined(separator: ",")
            csvContent += row + "\n"
        }
        
        try csvContent.write(toFile: filePath, atomically: true, encoding: .utf8)
        print("QuickBooks CSV written to: \(filePath)")
    }
    
    // Legacy function kept for compatibility
    private static func parseCSVLine(_ line: String) -> [String] {
        var values: [String] = []
        var currentValue = ""
        var insideQuotes = false
        var i = line.startIndex
        
        while i < line.endIndex {
            let char = line[i]
            
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                values.append(currentValue.trimmingCharacters(in: .whitespacesAndNewlines))
                currentValue = ""
            } else {
                currentValue.append(char)
            }
            
            i = line.index(after: i)
        }
        
        values.append(currentValue.trimmingCharacters(in: .whitespacesAndNewlines))
        return values
    }
}

class TransactionConverter {
    static func convertStripeToQuickBooks(_ stripeTransactions: [StripeTransaction]) -> [QuickBooksTransaction] {
        var quickBooksTransactions: [QuickBooksTransaction] = []
        var totalFees: Double = 0
        var earliestDate: Date?
        
        for stripe in stripeTransactions {
            // Create main transaction entry (gross amount)
            let mainTransaction = QuickBooksTransaction(
                date: stripe.created,
                description: stripe.customerName ?? "Unknown Customer",
                amount: stripe.amount, // Gross amount
                category: categorizeTransaction(stripe),
                account: "Stripe",
                customerName: stripe.customerName,
                memo: "Stripe ID: \(stripe.id)"
            )
            quickBooksTransactions.append(mainTransaction)
            
            // Accumulate fees and track earliest date
            if stripe.fee > 0 {
                totalFees += stripe.fee
                if earliestDate == nil || stripe.created < earliestDate! {
                    earliestDate = stripe.created
                }
            }
        }
        
        // Create single combined fee transaction if there are any fees
        if totalFees > 0, let feeDate = earliestDate {
            let combinedFeeTransaction = QuickBooksTransaction(
                date: feeDate,
                description: "Stripe fee",
                amount: -totalFees, // Negative total fee amount
                category: "Payment Processing Fees",
                account: "Stripe",
                customerName: nil,
                memo: "Combined fees for \(stripeTransactions.count) transactions"
            )
            quickBooksTransactions.append(combinedFeeTransaction)
        }
        
        return quickBooksTransactions
    }
    
    private static func categorizeTransaction(_ transaction: StripeTransaction) -> String {
        switch transaction.type.lowercased() {
        case "charge":
            return "Sales Income"
        case "refund":
            return "Refunds"
        case "payout":
            return "Transfer to Bank"
        case "adjustment":
            return "Adjustments"
        case "application_fee":
            return "Application Fees"
        case "application_fee_refund":
            return "Application Fee Refunds"
        case "transfer":
            return "Transfers"
        default:
            return "Other Income"
        }
    }
    
    static func generateSummaryReport(_ stripeTransactions: [StripeTransaction]) -> String {
        let totalGross = stripeTransactions.reduce(0) { $0 + $1.amount }
        let totalFees = stripeTransactions.reduce(0) { $0 + $1.fee }
        let totalNet = stripeTransactions.reduce(0) { $0 + $1.net }
        let transactionCount = stripeTransactions.count
        
        var report = """
        Stripe to QuickBooks Conversion Summary
        =====================================
        
        Total Transactions: \(transactionCount)
        Total Gross Amount: $\(String(format: "%.2f", totalGross))
        Total Fees: $\(String(format: "%.2f", totalFees))
        Total Net Amount: $\(String(format: "%.2f", totalNet))
        
        Transaction Breakdown by Type:
        """
        
        let groupedByType = Dictionary(grouping: stripeTransactions) { $0.type }
        for (type, transactions) in groupedByType.sorted(by: { $0.key < $1.key }) {
            let typeGross = transactions.reduce(0) { $0 + $1.amount }
            let typeFees = transactions.reduce(0) { $0 + $1.fee }
            report += "\n- \(type): \(transactions.count) transactions, $\(String(format: "%.2f", typeGross)) gross, $\(String(format: "%.2f", typeFees)) fees"
        }
        
        return report
    }
}

enum ConversionError: Error, LocalizedError {
    case fileNotFound(String)
    case invalidInput(String)
    case processingError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let message):
            return "File Error: \(message)"
        case .invalidInput(let message):
            return "Input Error: \(message)"
        case .processingError(let message):
            return "Processing Error: \(message)"
        }
    }
}

enum CSVError: Error {
    case emptyFile
    case invalidFormat
    case fileNotFound
}

// Main execution
func main() {
    let arguments = CommandLine.arguments
    
    if arguments.count < 2 {
        print("""
        Stripe to QuickBooks Converter v2.0.0
        
        Usage: \(arguments[0]) <input_file> [options]
        
        Arguments:
          input_file              Path to the Stripe CSV file
        
        Options:
          -o, --output <file>     Output CSV file path (optional)
          -r, --report            Generate a summary report
          -v, --verbose           Verbose output
        
        Example:
          \(arguments[0]) transfers-5.csv -o quickbooks.csv -r -v
        """)
        return
    }
    
    let inputFile = arguments[1]
    var outputFile: String?
    var verbose = false
    var generateReport = false
    
    for i in 2..<arguments.count {
        let arg = arguments[i]
        if arg == "-v" || arg == "--verbose" {
            verbose = true
        } else if arg == "-r" || arg == "--report" {
            generateReport = true
        } else if arg == "-o" || arg == "--output" {
            if i + 1 < arguments.count {
                outputFile = arguments[i + 1]
            }
        }
    }
    
    do {
        if verbose {
            print("Starting Stripe to QuickBooks conversion...")
            print("Input file: \(inputFile)")
        }
        
        guard FileManager.default.fileExists(atPath: inputFile) else {
            throw ConversionError.fileNotFound("Input file not found: \(inputFile)")
        }
        
        let finalOutputFile = outputFile ?? {
            let url = URL(fileURLWithPath: inputFile)
            let nameWithoutExtension = url.deletingPathExtension().lastPathComponent
            let directory = url.deletingLastPathComponent().path
            return "\(directory)/\(nameWithoutExtension)_quickbooks.csv"
        }()
        
        if verbose {
            print("Output file: \(finalOutputFile)")
        }
        
        if verbose {
            print("Parsing Stripe CSV...")
        }
        let stripeTransactions = try CSVParser.parseStripeCSV(from: inputFile)
        
        if verbose {
            print("Found \(stripeTransactions.count) transactions")
        }
        
        if stripeTransactions.isEmpty {
            print("⚠️  Warning: No transactions were parsed from the CSV file.")
            print("This could mean:")
            print("- The CSV format doesn't match expected Stripe format")
            print("- The file is empty or contains only headers")
            print("- There are parsing errors")
            return
        }
        
        if verbose {
            print("Converting to QuickBooks format...")
        }
        let quickBooksTransactions = TransactionConverter.convertStripeToQuickBooks(stripeTransactions)
        
        if verbose {
            print("Writing QuickBooks CSV...")
        }
        try CSVParser.writeQuickBooksCSV(transactions: quickBooksTransactions, to: finalOutputFile)
        
        print("✅ Conversion completed successfully!")
        print("📄 Output file: \(finalOutputFile)")
        print("📊 Converted \(stripeTransactions.count) Stripe transactions to \(quickBooksTransactions.count) QuickBooks entries")
        
        if generateReport {
            let summaryReport = TransactionConverter.generateSummaryReport(stripeTransactions)
            print("\n" + summaryReport)
            
            let reportFile = finalOutputFile.replacingOccurrences(of: ".csv", with: "_report.txt")
            try summaryReport.write(toFile: reportFile, atomically: true, encoding: .utf8)
            print("\n📋 Summary report saved to: \(reportFile)")
        }
        
    } catch {
        print("❌ Error: \(error.localizedDescription)")
        exit(1)
    }
}

main()