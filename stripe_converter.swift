import Foundation

// Simple, standalone Stripe to QuickBooks converter

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
    
    init?(from csvRow: [String: String]) {
        guard let id = csvRow["id"],
              let createdString = csvRow["created"],
              let amountString = csvRow["amount"],
              let feeString = csvRow["fee"],
              let netString = csvRow["net"],
              let currency = csvRow["currency"],
              let type = csvRow["type"],
              let description = csvRow["description"] else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let created = formatter.date(from: createdString),
              let amount = Double(amountString),
              let fee = Double(feeString),
              let net = Double(netString) else {
            return nil
        }
        
        self.id = id
        self.created = created
        self.amount = amount / 100.0
        self.currency = currency
        self.fee = fee / 100.0
        self.net = net / 100.0
        self.type = type
        self.description = description
        self.sourceId = csvRow["source_id"]
        self.customerId = csvRow["customer_id"]
    }
}

struct QuickBooksTransaction {
    let date: Date
    let description: String
    let amount: Double
    let category: String
    let account: String
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
            memo ?? ""
        ]
    }
    
    static var csvHeaders: [String] {
        return ["Date", "Description", "Amount", "Category", "Account", "Memo"]
    }
}

class CSVParser {
    static func parseStripeCSV(from filePath: String) throws -> [StripeTransaction] {
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        guard let headerLine = lines.first else {
            throw ConversionError.invalidInput("Empty file")
        }
        
        let headers = headerLine.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        var transactions: [StripeTransaction] = []
        
        for line in lines.dropFirst() {
            let values = parseCSVLine(line)
            guard values.count == headers.count else { continue }
            
            var rowDict: [String: String] = [:]
            for (index, header) in headers.enumerated() {
                rowDict[header] = values[index]
            }
            
            if let transaction = StripeTransaction(from: rowDict) {
                transactions.append(transaction)
            }
        }
        
        return transactions
    }
    
    static func writeQuickBooksCSV(transactions: [QuickBooksTransaction], to filePath: String) throws {
        var csvContent = QuickBooksTransaction.csvHeaders.joined(separator: ",") + "\n"
        
        for transaction in transactions {
            let row = transaction.toCSVRow().map { "\"\($0)\"" }.joined(separator: ",")
            csvContent += row + "\n"
        }
        
        try csvContent.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
    
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
        
        for stripe in stripeTransactions {
            let mainTransaction = QuickBooksTransaction(
                date: stripe.created,
                description: stripe.description,
                amount: stripe.amount,
                category: categorizeTransaction(stripe),
                account: "Stripe",
                memo: "Stripe Transaction ID: \(stripe.id)"
            )
            quickBooksTransactions.append(mainTransaction)
            
            if stripe.fee > 0 {
                let feeTransaction = QuickBooksTransaction(
                    date: stripe.created,
                    description: "Stripe Processing Fee - \(stripe.description)",
                    amount: -stripe.fee,
                    category: "Payment Processing Fees",
                    account: "Stripe",
                    memo: "Fee for transaction: \(stripe.id)"
                )
                quickBooksTransactions.append(feeTransaction)
            }
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

// Main execution
func main() {
    let arguments = CommandLine.arguments
    
    if arguments.count < 2 {
        print("""
        Stripe to QuickBooks Converter v1.0.0
        
        Usage: \(arguments[0]) <input_file> [options]
        
        Arguments:
          input_file              Path to the Stripe CSV file
        
        Options:
          -o, --output <file>     Output CSV file path (optional)
          -r, --report            Generate a summary report
          -v, --verbose           Verbose output
        
        Example:
          \(arguments[0]) stripe_data.csv -o quickbooks.csv -r -v
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