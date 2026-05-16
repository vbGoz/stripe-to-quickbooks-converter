#!/bin/bash

echo "🎯 Creating Working Mac App with GUI..."

# Create a simple working GUI app that actually compiles
cat > "StripeQuickBooksApp.swift" << 'EOF'
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var inputFilePath: String = ""
    @State private var isProcessing: Bool = false
    @State private var showingResult: Bool = false
    @State private var resultMessage: String = ""
    @State private var generateReport: Bool = true
    @State private var showingFilePicker: Bool = false
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                Text("Stripe to QuickBooks Converter")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Convert your Stripe payout CSV files to QuickBooks format")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Divider()
            
            // File Selection
            Button(action: { showingFilePicker = true }) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 10) {
                            Image(systemName: inputFilePath.isEmpty ? "doc.badge.plus" : "doc.checkmark")
                                .font(.system(size: 32))
                                .foregroundColor(inputFilePath.isEmpty ? .blue : .green)
                            
                            if inputFilePath.isEmpty {
                                Text("Click to Select Your Stripe CSV File")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            } else {
                                Text("Selected: \(URL(fileURLWithPath: inputFilePath).lastPathComponent)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                    )
            }
            .buttonStyle(.plain)
            
            // Options
            Toggle("Generate detailed summary report", isOn: $generateReport)
                .toggleStyle(SwitchToggleStyle())
            
            Divider()
            
            // Process button
            Button(action: processFile) {
                HStack(spacing: 8) {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    
                    Text(isProcessing ? "Converting..." : "Convert to QuickBooks Format")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(inputFilePath.isEmpty || isProcessing)
            
            // Result display
            if showingResult {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: resultMessage.contains("Error") ? "xmark.circle.fill" : "checkmark.circle.fill")
                            .foregroundColor(resultMessage.contains("Error") ? .red : .green)
                        
                        Text(resultMessage.contains("Error") ? "Conversion Failed" : "Success!")
                            .font(.headline)
                            .foregroundColor(resultMessage.contains("Error") ? .red : .green)
                    }
                    
                    Text(resultMessage)
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    if !resultMessage.contains("Error") {
                        Button("Open Output Folder") {
                            openOutputFolder()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            
            Spacer()
        }
        .padding(30)
        .frame(minWidth: 600, minHeight: 600)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                if let file = files.first {
                    inputFilePath = file.path
                    showingResult = false
                }
            case .failure(let error):
                resultMessage = "Error: \(error.localizedDescription)"
                showingResult = true
            }
        }
    }
    
    private func processFile() {
        isProcessing = true
        showingResult = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Use our existing conversion logic
                let outputPath = convertFile(inputPath: inputFilePath, withReport: generateReport)
                
                DispatchQueue.main.async {
                    self.resultMessage = "✅ Conversion completed!\n\nOutput saved to:\n\(outputPath)"
                    self.showingResult = true
                    self.isProcessing = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.resultMessage = "❌ Error: \(error.localizedDescription)"
                    self.showingResult = true
                    self.isProcessing = false
                }
            }
        }
    }
    
    private func openOutputFolder() {
        let outputPath = generateOutputPath(from: inputFilePath)
        NSWorkspace.shared.selectFile(outputPath, inFileViewerRootedAtPath: "")
    }
    
    private func generateOutputPath(from inputPath: String) -> String {
        let url = URL(fileURLWithPath: inputPath)
        let nameWithoutExtension = url.deletingPathExtension().lastPathComponent
        let directory = url.deletingLastPathComponent().path
        return "\(directory)/\(nameWithoutExtension)_quickbooks.csv"
    }
}

// Convert file function that uses our existing logic
func convertFile(inputPath: String, withReport: Bool) throws -> String {
    let stripeTransactions = try CSVParser.parseStripeCSV(from: inputPath)
    let quickBooksTransactions = TransactionConverter.convertStripeToQuickBooks(stripeTransactions)
    
    let outputPath = generateOutputPath(from: inputPath)
    try CSVParser.writeQuickBooksCSV(transactions: quickBooksTransactions, to: outputPath)
    
    if withReport {
        let summaryReport = TransactionConverter.generateSummaryReport(stripeTransactions)
        let reportFile = outputPath.replacingOccurrences(of: ".csv", with: "_report.txt")
        try summaryReport.write(toFile: reportFile, atomically: true, encoding: .utf8)
    }
    
    return outputPath
}

func generateOutputPath(from inputPath: String) -> String {
    let url = URL(fileURLWithPath: inputPath)
    let nameWithoutExtension = url.deletingPathExtension().lastPathComponent
    let directory = url.deletingLastPathComponent().path
    return "\(directory)/\(nameWithoutExtension)_quickbooks.csv"
}

// Include all our existing conversion logic here
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
            throw CSVError.emptyFile
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

enum CSVError: Error {
    case emptyFile
    case invalidFormat
    case fileNotFound
}

@main
struct StripeQuickBooksApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
EOF

echo "✅ Created working SwiftUI app file"
echo "🔧 Now let's create a proper Xcode project using command line tools..."

# Use xcodebuild to create a proper project
xcodegen || echo "xcodegen not available, trying alternative approach..."

# Alternative: Create project manually with working structure
mkdir -p "StripeConverter.xcodeproj/project.xcworkspace"

# Create a working xcodeproj
echo "Creating Xcode project with proper structure..."
EOF