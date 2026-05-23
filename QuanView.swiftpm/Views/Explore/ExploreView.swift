import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var progressManager: UserProgressManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(white: 0.035), Color(red: 0.02, green: 0.08, blue: 0.09), Color(white: 0.04)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        headerSection
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("EXPERIMENTS")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.45))
                                .tracking(3)
                                .padding(.horizontal)
                            
                            ForEach(QuantumConcept.allCases) { concept in
                                NavigationLink(destination: VisualiserView(initialConcept: concept)) {
                                    ExperimentCard(
                                        concept: concept,
                                        isCompleted: progressManager.completedConcepts.contains(concept)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Explore")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileToolbarButton()
                }
            }
        }
    }
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("QUANVIEW LAB")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.cyan)
                        .tracking(4)
                    Text("Choose an experiment, then inspect it in the room or in AR.")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Image(systemName: "cube.transparent")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(.cyan)
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(progressManager.completedConcepts.count) / \(QuantumConcept.allCases.count) Experiments Logged")
                    Spacer()
                    Text("\(Int(progressManager.completionRatio * 100))%")
                }
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.white.opacity(0.65))
                
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.08))
                        Capsule()
                            .fill(.cyan)
                            .frame(width: max(8, proxy.size.width * progressManager.completionRatio))
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(24)
    }
}

struct ExperimentCard: View {
    let concept: QuantumConcept
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(concept.themeColor.opacity(isCompleted ? 0.22 : 0.12))
                    .frame(width: 52, height: 52)
                
                Image(systemName: isCompleted ? "checkmark.seal.fill" : "cube.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(concept.themeColor)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(concept.title.uppercased())
                    .font(.system(.subheadline, design: .monospaced))
                    .bold()
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(concept.tagline)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(2)
                Text(concept.modelAssetName + ".usdz")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.36))
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(isCompleted ? "LOGGED" : "READY")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(isCompleted ? concept.themeColor : .white.opacity(0.42))
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
        .padding(14)
        .background(.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isCompleted ? concept.themeColor.opacity(0.35) : .white.opacity(0.06), lineWidth: 1)
        )
    }
}
