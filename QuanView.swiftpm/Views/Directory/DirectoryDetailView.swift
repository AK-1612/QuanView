import SwiftUI

struct DirectoryDetailView: View {
    let item: DirectoryItem
    
    // Auxiliary state for 3D viewer
    @State private var isAnimating = true
    @State private var resetView = false
    @State private var zoomCommand = 0
    @State private var interactionCommand = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Top: 3D Scene View
                ModelViewerContainer(
                    concept: item.concept,
                    isAnimating: $isAnimating,
                    resetView: $resetView,
                    zoomCommand: $zoomCommand,
                    interactionCommand: $interactionCommand,
                    slideIndex: -1
                )
                .frame(height: UIScreen.main.bounds.height * 0.3)
                .background(Color(white: 0.02))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(item.concept.themeColor.opacity(0.18), lineWidth: 1)
                )
                
                // Title and Subtitle Block
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        
                        Text(item.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    // Large Symbol Badge
                    Text(item.symbol)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .italic()
                        .foregroundStyle(item.concept.themeColor)
                        .multilineTextAlignment(.trailing)
                        .minimumScaleFactor(0.4)
                        .lineLimit(2)
                        .frame(maxWidth: 140, alignment: .trailing)
                }
                .padding(.horizontal, 4)
                
                // Properties Sheet
                propertiesTableCard
                
                // Explanation block
                infoSection(
                    title: "PHYSICAL MECHANICS",
                    icon: "atom",
                    color: item.concept.themeColor
                ) {
                    Text(item.explanation)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(5)
                }
                
                // Application block
                infoSection(
                    title: "REAL-WORLD APPLICATIONS",
                    icon: "cpu",
                    color: .cyan
                ) {
                    Text(item.application)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(5)
                }
            }
            .padding(16)
            .padding(.bottom, 32)
        }
        .background(Color(white: 0.035).ignoresSafeArea())
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Properties Table Card
    
    var propertiesTableCard: some View {
        VStack(spacing: 0) {
            let sortedKeys = item.properties.keys.sorted()
            ForEach(0..<sortedKeys.count, id: \.self) { idx in
                let key = sortedKeys[idx]
                HStack {
                    Text(key.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.gray)
                        .frame(width: 120, alignment: .leading)
                    
                    Text(item.properties[key] ?? "—")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                
                if idx < sortedKeys.count - 1 {
                    Divider().background(Color.white.opacity(0.08))
                }
            }
        }
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: - Section Helper
    
    @ViewBuilder
    func infoSection<Content: View>(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
                    .tracking(1.5)
            }
            
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}
