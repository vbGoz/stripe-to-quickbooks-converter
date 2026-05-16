import Foundation

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