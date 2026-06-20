import SwiftUI

struct LearnListView: View {
    @EnvironmentObject var progressManager: UserProgressManager
    @State private var showingProfile = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.035).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Banner
                        VStack(alignment: .leading, spacing: 8) {
                            Text("QUANTUM LESSONS")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(.cyan)
                                .tracking(2)
                            
                            Text("Master the Subatomic World")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("Work through sequential, interactive 3D lessons designed to build core intuition of quantum anomalies.")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .lineSpacing(3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Lesson Cards list
                        VStack(spacing: 16) {
                            ForEach(QuantumConcept.allCases) { concept in
                                NavigationLink(destination: InteractiveLessonView(concept: concept)) {
                                    LessonListCard(
                                        concept: concept,
                                        isCompleted: progressManager.completedConcepts.contains(concept)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileToolbarButton()
                }
            }
        }
    }
}

struct LessonListCard: View {
    let concept: QuantumConcept
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon box
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(concept.themeColor.opacity(0.12))
                    .frame(width: 56, height: 56)
                
                Image(systemName: isCompleted ? "checkmark.seal.fill" : "graduationcap.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(concept.themeColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("MODULE \(concept.experimentNumber)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(concept.themeColor)
                    
                    Spacer()
                    
                    if isCompleted {
                        Text("COMPLETED")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                
                Text(concept.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text(concept.tagline)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.25))
        }
        .padding(16)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(concept.themeColor.opacity(isCompleted ? 0.3 : 0.12), lineWidth: 1)
        )
    }
}
