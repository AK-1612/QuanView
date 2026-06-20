import SwiftUI
import CoreLocation

// MARK: - Level 1: Experiment cards

struct LabNotebookView: View {
    @EnvironmentObject var progressManager: UserProgressManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.045).ignoresSafeArea()

                if progressManager.records.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(QuantumConcept.allCases) { concept in
                                let logs = progressManager.records.filter { $0.concept == concept }
                                if !logs.isEmpty {
                                    NavigationLink(destination: ConceptLogsView(concept: concept, logs: logs)) {
                                        ExperimentNotebookCard(concept: concept, logs: logs)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Logs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileToolbarButton()
                }
            }
        }
    }

    var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "doc.viewfinder")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(.cyan)
            Text("No Logs Yet")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text("Capture an AR experiment snapshot\nand it will appear here.")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(40)
    }
}

// MARK: - Experiment notebook card (Level 1)

struct ExperimentNotebookCard: View {
    let concept: QuantumConcept
    let logs: [LabRecord]

    var latestLog: LabRecord? { logs.first }

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail from latest log
            Group {
                if let img = latestLog?.uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        concept.themeColor.opacity(0.15)
                        Image(systemName: "cube.fill")
                            .font(.title2)
                            .foregroundStyle(concept.themeColor)
                    }
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(concept.themeColor.opacity(0.3), lineWidth: 1))

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("EXP \(concept.experimentNumber)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(concept.themeColor)
                    Text(concept.title)
                        .font(.system(.subheadline).bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                Text(concept.tagline)
                    .font(.caption)
                    .foregroundStyle(.gray)
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 10))
                    Text("\(logs.count) \(logs.count == 1 ? "log" : "logs")")
                        .font(.system(size: 12, design: .monospaced))
                }
                .foregroundStyle(concept.themeColor.opacity(0.8))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(14)
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(concept.themeColor.opacity(0.18), lineWidth: 1)
        )
    }
}

// MARK: - Level 2: Log cards for a concept

struct ConceptLogsView: View {
    let concept: QuantumConcept
    let logs: [LabRecord]
    @EnvironmentObject var progressManager: UserProgressManager

    var body: some View {
        ZStack {
            Color(white: 0.045).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    // Concept header
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(concept.themeColor.opacity(0.15))
                                .frame(width: 48, height: 48)
                            Image(systemName: "cube.fill")
                                .font(.title3)
                                .foregroundStyle(concept.themeColor)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(concept.title)
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                            Text(concept.description)
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color(white: 0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Log cards
                    ForEach(logs) { log in
                        NavigationLink(destination: LogDetailView(record: log)) {
                            LogCard(record: log)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Experiment \(concept.experimentNumber)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Log card (Level 2)

struct LogCard: View {
    let record: LabRecord

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            // Photo thumbnail
            Group {
                if let img = record.uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color(white: 0.15)
                        .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 5) {
                Text(Self.formatter.string(from: record.timestamp))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                Text(record.aiAnalysis
                    .components(separatedBy: "\n")
                    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                    .first ?? "Analysis pending…")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.gray)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(12)
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.07), lineWidth: 1))
    }
}

// MARK: - Level 3: Log detail with PDF export

struct LogDetailView: View {
    let record: LabRecord
    @State private var showShareSheet = false
    @State private var pdfData: Data?
    @StateObject private var locationFetcher = LocationFetcher()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Photo
                if let img = record.uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }

                // Metadata block
                metadataBlock

                // Experiment info
                infoBlock(
                    title: "EXPERIMENT",
                    icon: "cube.fill",
                    color: record.concept.themeColor
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(record.concept.title)
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                        Text(record.concept.description)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))
                            .lineSpacing(4)
                        Text(record.concept.tagline.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(record.concept.themeColor)
                            .padding(.top, 2)
                    }
                }

                // AI Analysis
                infoBlock(
                    title: "FOUNDATION MODEL ANALYSIS",
                    icon: "brain",
                    color: .cyan
                ) {
                    Text(record.aiAnalysis)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(5)
                }
            }
            .padding(16)
            .padding(.bottom, 32)
        }
        .background(Color(white: 0.045).ignoresSafeArea())
        .navigationTitle("Log Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    pdfData = buildPDF()
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let data = pdfData {
                ShareSheet(items: [data])
            }
        }
        .onAppear { locationFetcher.start() }
    }

    // MARK: Metadata block

    var metadataBlock: some View {
        VStack(spacing: 0) {
            metaRow(label: "DATE", value: record.timestamp.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
            Divider().background(Color.white.opacity(0.08))
            metaRow(label: "TIME", value: record.timestamp.formatted(.dateTime.hour().minute().second()))
            Divider().background(Color.white.opacity(0.08))
            metaRow(label: "EXPERIMENT", value: "Exp. \(record.concept.experimentNumber) — \(record.concept.title)")
            Divider().background(Color.white.opacity(0.08))
            metaRow(label: "LOCATION", value: locationFetcher.locationString)
        }
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    func metaRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.gray)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(.white)
                .lineLimit(2)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    func infoBlock<Content: View>(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
                    .tracking(1)
            }
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.2), lineWidth: 1))
    }

    // MARK: PDF builder

    func buildPDF() -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { ctx in
            ctx.beginPage()
            let g = ctx.cgContext

            // Background
            g.setFillColor(UIColor(white: 0.06, alpha: 1).cgColor)
            g.fill(pageRect)

            var y: CGFloat = 40

            // Header
            let headerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 9, weight: .bold),
                .foregroundColor: UIColor.systemCyan
            ]
            "QUANVIEW — LABORATORY LOG".draw(at: CGPoint(x: 40, y: y), withAttributes: headerAttrs)
            y += 20

            // Title
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.white
            ]
            record.concept.title.draw(at: CGPoint(x: 40, y: y), withAttributes: titleAttrs)
            y += 30

            // Divider
            g.setStrokeColor(UIColor.white.withAlphaComponent(0.15).cgColor)
            g.setLineWidth(0.5)
            g.move(to: CGPoint(x: 40, y: y)); g.addLine(to: CGPoint(x: 555, y: y)); g.strokePath()
            y += 14

            // Metadata
            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 8, weight: .bold),
                .foregroundColor: UIColor.gray
            ]
            let valueAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor.white
            ]

            let dateStr = record.timestamp.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
            let timeStr = record.timestamp.formatted(.dateTime.hour().minute().second())

            for (label, value) in [("DATE", dateStr), ("TIME", timeStr), ("EXPERIMENT", "Exp. \(record.concept.experimentNumber) — \(record.concept.title)"), ("LOCATION", locationFetcher.locationString)] {
                label.draw(at: CGPoint(x: 40, y: y), withAttributes: labelAttrs)
                value.draw(at: CGPoint(x: 130, y: y), withAttributes: valueAttrs)
                y += 16
            }
            y += 10

            // Photo
            if let img = record.uiImage {
                let maxW: CGFloat = 515
                let aspect = img.size.height / img.size.width
                let imgH = min(maxW * aspect, 260)
                let imgRect = CGRect(x: 40, y: y, width: maxW, height: imgH)
                img.draw(in: imgRect)
                y += imgH + 14
            }

            // Divider
            g.setStrokeColor(UIColor.white.withAlphaComponent(0.15).cgColor)
            g.move(to: CGPoint(x: 40, y: y)); g.addLine(to: CGPoint(x: 555, y: y)); g.strokePath()
            y += 14

            // Experiment description
            "EXPERIMENT".draw(at: CGPoint(x: 40, y: y), withAttributes: labelAttrs)
            y += 14
            let descAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.white
            ]
            let descRect = CGRect(x: 40, y: y, width: 515, height: 60)
            record.concept.description.draw(in: descRect, withAttributes: descAttrs)
            y += 70

            // Analysis
            "FOUNDATION MODEL ANALYSIS".draw(at: CGPoint(x: 40, y: y), withAttributes: labelAttrs)
            y += 14
            let analysisAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor(white: 0.85, alpha: 1)
            ]
            let analysisRect = CGRect(x: 40, y: y, width: 515, height: 200)
            record.aiAnalysis.draw(in: analysisRect, withAttributes: analysisAttrs)

            // Footer
            let footerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 8, weight: .regular),
                .foregroundColor: UIColor.gray
            ]
            "Generated by QuanView · \(Date().formatted())".draw(at: CGPoint(x: 40, y: 800), withAttributes: footerAttrs)
        }
    }
}

// MARK: - New Log picker

struct NewLogPickerView: View {
    @EnvironmentObject var progressManager: UserProgressManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.045).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(QuantumConcept.allCases) { concept in
                            NavigationLink(destination:
                                QuantumSandboxView(concept: concept)
                                    .environmentObject(progressManager)
                                    .onDisappear { dismiss() }
                            ) {
                                NewLogConceptRow(
                                    concept: concept,
                                    isLogged: progressManager.completedConcepts.contains(concept)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Select Experiment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct NewLogConceptRow: View {
    let concept: QuantumConcept
    let isLogged: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(concept.themeColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text("\(concept.experimentNumber)")
                    .font(.system(.headline, design: .monospaced).bold())
                    .foregroundStyle(concept.themeColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(concept.title)
                    .font(.system(.body).bold())
                    .foregroundStyle(.white)
                Text(concept.tagline)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            if isLogged {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(concept.themeColor)
            }

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(14)
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.07), lineWidth: 1))
    }
}

// MARK: - Location helper

@MainActor
class LocationFetcher: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var locationString = "—"
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var didStart = false

    func start() {
        guard !didStart else { return }
        didStart = true
        // Only attempt location if the plist key is present (Swift Playgrounds auto-adds it
        // when the capability is declared; gracefully degrade otherwise)
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else {
            locationString = "Not authorized"
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else if status != .notDetermined {
            Task { @MainActor in self.locationString = "Not authorized" }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        Task { @MainActor in
            self.geocoder.reverseGeocodeLocation(loc) { placemarks, _ in
                Task { @MainActor in
                    if let p = placemarks?.first {
                        self.locationString = [p.locality, p.administrativeArea, p.country]
                            .compactMap { $0 }
                            .joined(separator: ", ")
                    } else {
                        self.locationString = String(format: "%.4f°, %.4f°", loc.coordinate.latitude, loc.coordinate.longitude)
                    }
                }
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in self.locationString = "Unavailable" }
    }
}

// MARK: - UIActivityViewController wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
