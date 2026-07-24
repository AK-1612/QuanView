import SwiftUI

struct DirectoryListView: View {
    @StateObject private var viewModel = DirectoryViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.035).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                        TextField("Search particles or equations...", text: $viewModel.searchText)
                            .textFieldStyle(.plain)
                            .foregroundStyle(.white)
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(white: 0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    // Category Selector
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("All").tag(nil as DirectoryCategory?)
                        ForEach(DirectoryCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat as DirectoryCategory?)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    
                    // Results list
                    if viewModel.filteredItems.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.filteredItems) { item in
                                    NavigationLink(destination: DirectoryDetailView(item: item)) {
                                        DirectoryListRow(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
            .navigationTitle("Directory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileToolbarButton()
                }
            }
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(.gray)
            Text("No Results Found")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Try searching for common terms like 'Photon', 'Electron', or 'Schrödinger'.")
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}

struct DirectoryListRow: View {
    let item: DirectoryItem
    
    var body: some View {
        HStack(spacing: 14) {
            // Symbol badge
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(item.concept.themeColor.opacity(0.12))
                
                Text(item.symbol)
                    .font(.system(size: 13, weight: .bold, design: .serif).italic())
                    .foregroundStyle(item.concept.themeColor)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.35)
                    .lineLimit(2)
                    .padding(4)
            }
            .frame(width: 56, height: 56)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Category tag
            Text(item.category == .particle ? "PARTICLE" : "EQUATION")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(item.concept.themeColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(item.concept.themeColor.opacity(0.08))
                .clipShape(Capsule())
        }
        .padding(14)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(item.concept.themeColor.opacity(0.12), lineWidth: 1)
        )
    }
}
