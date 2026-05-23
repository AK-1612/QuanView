import SwiftUI

struct LabNotebookView: View {
    @EnvironmentObject var progressManager: UserProgressManager
    @State private var selectedFilter: QuantumConcept?
    @State private var searchText = ""
    
    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    var visibleRecords: [LabRecord] {
        let filteredRecords: [LabRecord]
        if let selectedFilter {
            filteredRecords = progressManager.records.filter { $0.concept == selectedFilter }
        } else {
            filteredRecords = progressManager.records
        }
        
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return filteredRecords
        }
        
        return filteredRecords.filter {
            $0.concept.title.localizedCaseInsensitiveContains(searchText)
            || $0.concept.tagline.localizedCaseInsensitiveContains(searchText)
            || $0.aiAnalysis.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.045).ignoresSafeArea()
                
                if progressManager.records.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            filterBar
                            
                            if visibleRecords.isEmpty {
                                filteredEmptyState
                            } else {
                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(visibleRecords) { record in
                                        NavigationLink(destination: LabDetailView(record: record)) {
                                            NotebookCard(record: record)
                                                .onTapGesture {
                                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Research Logs")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search logs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileToolbarButton()
                }
            }
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "doc.viewfinder")
                .font(.system(size: 54, weight: .light))
                .foregroundStyle(.cyan)
            Text("No Logs Recorded")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text("Capture an AR simulation snapshot and the notebook will assemble the scan, timestamp, and analysis here.")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(40)
    }
    
    var filteredEmptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title)
                .foregroundStyle(.gray)
            Text("No matching logs")
                .font(.headline)
                .foregroundStyle(.white)
            Button("Clear Filters") {
                selectedFilter = nil
                searchText = ""
            }
            .font(.system(.caption, design: .monospaced).bold())
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 64)
    }
    
    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedFilter == nil, color: .cyan) {
                    selectedFilter = nil
                }
                
                ForEach(QuantumConcept.allCases) { concept in
                    FilterChip(title: concept.title, isSelected: selectedFilter == concept, color: concept.themeColor) {
                        selectedFilter = concept
                    }
                }
            }
        }
    }
}

struct NotebookCard: View {
    let record: LabRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let img = record.uiImage {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 136)
                    .clipped()
            } else {
                Rectangle()
                    .fill(.white.opacity(0.06))
                    .frame(height: 136)
                    .overlay(Image(systemName: "photo").foregroundStyle(.gray))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(record.concept.title.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(record.concept.themeColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(record.timestamp.formatted(.dateTime.month().day().hour().minute()))
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            .padding(11)
        }
        .background(Color(white: 0.115))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.09), lineWidth: 1))
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundStyle(isSelected ? .black : .white.opacity(0.76))
                .lineLimit(1)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(isSelected ? color : Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct LabDetailView: View {
    let record: LabRecord
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let img = record.uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.1), lineWidth: 1))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("LABORATORY ANALYSIS")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(record.concept.themeColor)
                    
                    Text(record.aiAnalysis)
                        .font(.system(.body, design: .monospaced))
                        .lineSpacing(6)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("TIMESTAMP").font(.caption2).foregroundStyle(.gray)
                            Text(record.timestamp.formatted())
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("FIELD TYPE").font(.caption2).foregroundStyle(.gray)
                            Text("Quantum AR Scan")
                        }
                    }
                    .font(.system(.subheadline, design: .monospaced))
                    .padding(.top, 10)
                }
            }
            .padding()
        }
        .background(Color(white: 0.05).ignoresSafeArea())
        .navigationTitle(record.concept.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let image = record.uiImage {
                ShareLink(item: Image(uiImage: image), preview: SharePreview("Quantum Log", image: Image(uiImage: image))) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}
