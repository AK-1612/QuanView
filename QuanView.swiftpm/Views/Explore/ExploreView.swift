import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var progressManager: UserProgressManager
    
    var body: some View {
        NavigationStack {
            List {
                // Experiment cards
                Section("Experiments") {
                    ForEach(QuantumConcept.allCases) { concept in
                        NavigationLink(destination: VisualiserView(initialConcept: concept)) {
                            ExperimentCard(
                                concept: concept,
                                isCompleted: progressManager.completedConcepts.contains(concept)
                            )
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Labs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileToolbarButton()
                }
            }
        }
    }
}

struct ExperimentCard: View {
    let concept: QuantumConcept
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(concept.themeColor.opacity(0.2))
                
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "cube.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(concept.themeColor)
            }
            .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(concept.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(concept.tagline)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .contentShape(Rectangle())
    }
}
