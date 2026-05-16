import Foundation

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