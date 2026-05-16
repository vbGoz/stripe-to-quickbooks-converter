import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var inputFilePath: String = ""
    @State private var outputFilePath: String = ""
    @State private var isProcessing: Bool = false
    @State private var showingResult: Bool = false
    @State private var resultMessage: String = ""
    @State private var generateReport: Bool = true
    @State private var showingFilePicker: Bool = false
    @State private var showingSavePanel: Bool = false
    @State private var isDragOver: Bool = false
    @State private var conversionSummary: String = ""
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            headerSection
            
            Divider()
            
            // File Drop Zone
            fileDropZone
            
            // Options
            optionsSection
            
            Divider()
            
            // Process button
            processButton
            
            // Result display
            if showingResult {
                resultSection
            }
            
            Spacer()
        }
        .padding(30)
        .frame(minWidth: 600, minHeight: 700)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType.commaSeparatedText, UTType.text],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .fileMover(
            isPresented: $showingSavePanel,
            file: URL(fileURLWithPath: outputFilePath)
        ) { result in
            handleSaveLocation(result)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Stripe to QuickBooks Converter")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Convert your Stripe payout CSV files to QuickBooks format with automatic fee accounting")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var fileDropZone: some View {
        VStack(spacing: 20) {
            // Drop zone
            RoundedRectangle(cornerRadius: 12)
                .fill(isDragOver ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .stroke(isDragOver ? Color.blue : Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                .frame(height: 120)
                .overlay(
                    VStack(spacing: 10) {
                        Image(systemName: inputFilePath.isEmpty ? "doc.badge.plus" : "doc.checkmark")
                            .font(.system(size: 32))
                            .foregroundColor(inputFilePath.isEmpty ? .gray : .green)
                        
                        if inputFilePath.isEmpty {
                            Text("Drop your Stripe CSV file here")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("or click to browse")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Selected: \(URL(fileURLWithPath: inputFilePath).lastPathComponent)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Click to choose a different file")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                )
                .onTapGesture {
                    showingFilePicker = true
                }
                .onDrop(of: [UTType.fileURL], isTargeted: $isDragOver) { providers in
                    handleDrop(providers: providers)
                }
            
            // Output location
            VStack(alignment: .leading, spacing: 8) {
                Text("Output Location")
                    .font(.headline)
                
                HStack {
                    TextField("QuickBooks CSV will be saved automatically", text: .constant(generateOutputPreview()))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(true)
                    
                    Button("Choose Location") {
                        if !inputFilePath.isEmpty {
                            outputFilePath = generateDefaultOutputPath()
                            showingSavePanel = true
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(inputFilePath.isEmpty)
                }
            }
        }
    }
    
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Options")
                .font(.headline)
            
            Toggle("Generate detailed summary report", isOn: $generateReport)
                .toggleStyle(SwitchToggleStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var processButton: some View {
        Button(action: processFile) {
            HStack(spacing: 8) {
                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle())
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
    }
    
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: resultMessage.contains("Error") ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .foregroundColor(resultMessage.contains("Error") ? .red : .green)
                    .font(.title2)
                
                Text(resultMessage.contains("Error") ? "Conversion Failed" : "Conversion Complete!")
                    .font(.headline)
                    .foregroundColor(resultMessage.contains("Error") ? .red : .green)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(resultMessage)
                        .font(.body)
                        .textSelection(.enabled)
                    
                    if !conversionSummary.isEmpty && !resultMessage.contains("Error") {
                        Divider()
                        Text("Conversion Summary:")
                            .font(.headline)
                        Text(conversionSummary)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 200)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            if !resultMessage.contains("Error") {
                HStack {
                    Button("Open Output Folder") {
                        if !outputFilePath.isEmpty {
                            NSWorkspace.shared.selectFile(outputFilePath, inFileViewerRootedAtPath: "")
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Convert Another File") {
                        resetForm()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let files):
            if let file = files.first {
                inputFilePath = file.path
                outputFilePath = generateDefaultOutputPath()
                showingResult = false
            }
        case .failure(let error):
            resultMessage = "Error selecting file: \(error.localizedDescription)"
            showingResult = true
        }
    }
    
    private func handleSaveLocation(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            outputFilePath = url.path
        case .failure:
            break
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            
            DispatchQueue.main.async {
                self.inputFilePath = url.path
                self.outputFilePath = self.generateDefaultOutputPath()
                self.showingResult = false
            }
        }
        return true
    }
    
    private func generateDefaultOutputPath() -> String {
        guard !inputFilePath.isEmpty else { return "" }
        let url = URL(fileURLWithPath: inputFilePath)
        let nameWithoutExtension = url.deletingPathExtension().lastPathComponent
        let directory = url.deletingLastPathComponent().path
        return "\(directory)/\(nameWithoutExtension)_quickbooks.csv"
    }
    
    private func generateOutputPreview() -> String {
        guard !inputFilePath.isEmpty else { return "Select a Stripe CSV file first" }
        let url = URL(fileURLWithPath: outputFilePath.isEmpty ? generateDefaultOutputPath() : outputFilePath)
        return url.lastPathComponent
    }
    
    private func processFile() {
        isProcessing = true
        showingResult = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let stripeTransactions = try CSVParser.parseStripeCSV(from: inputFilePath)
                let quickBooksTransactions = TransactionConverter.convertStripeToQuickBooks(stripeTransactions)
                
                let finalOutputPath = outputFilePath.isEmpty ? generateDefaultOutputPath() : outputFilePath
                try CSVParser.writeQuickBooksCSV(transactions: quickBooksTransactions, to: finalOutputPath)
                
                var message = "✅ Successfully converted \(stripeTransactions.count) Stripe transactions to \(quickBooksTransactions.count) QuickBooks entries.\n\n📄 Output saved to:\n\(finalOutputPath)"
                
                var summary = ""
                if generateReport {
                    let summaryReport = TransactionConverter.generateSummaryReport(stripeTransactions)
                    let reportFile = finalOutputPath.replacingOccurrences(of: ".csv", with: "_report.txt")
                    try summaryReport.write(toFile: reportFile, atomically: true, encoding: .utf8)
                    message += "\n\n📋 Summary report saved to:\n\(reportFile)"
                    summary = summaryReport
                }
                
                DispatchQueue.main.async {
                    self.resultMessage = message
                    self.conversionSummary = summary
                    self.showingResult = true
                    self.isProcessing = false
                    self.outputFilePath = finalOutputPath
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.resultMessage = "❌ Error: \(error.localizedDescription)\n\nPlease check that your file is a valid Stripe CSV export."
                    self.conversionSummary = ""
                    self.showingResult = true
                    self.isProcessing = false
                }
            }
        }
    }
    
    private func resetForm() {
        inputFilePath = ""
        outputFilePath = ""
        showingResult = false
        resultMessage = ""
        conversionSummary = ""
    }
}