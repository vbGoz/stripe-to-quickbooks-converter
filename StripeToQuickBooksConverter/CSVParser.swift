import Foundation

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

enum CSVError: Error {
    case emptyFile
    case invalidFormat
    case fileNotFound
}