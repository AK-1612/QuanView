import SwiftUI

struct QuizHomeView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var levelToStart: QuizLevel? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.035).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("QUANTUM TESTING")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(.cyan)
                                .tracking(2)
                            
                            Text("Quantum Quizzes")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("Test your comprehension of probability, wavefunctions, non-locality, and high-dimensional space.")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .lineSpacing(3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Level Cards
                        VStack(spacing: 16) {
                            ForEach(QuizLevel.allCases) { level in
                                QuizLevelCard(
                                    level: level,
                                    highScore: viewModel.highScores[level.rawValue] ?? 0,
                                    action: {
                                        levelToStart = level
                                        viewModel.startQuiz(level: level)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileToolbarButton()
                }
            }
            .fullScreenCover(item: $levelToStart) { level in
                QuizPlayView(viewModel: viewModel)
            }
        }
    }
}

struct QuizLevelCard: View {
    let level: QuizLevel
    let highScore: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(level.themeColor.opacity(0.12))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(level.themeColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(level.themeColor)
                    
                    Text(level.rawValue + " Test")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Text(level.description)
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Score Box
                VStack(alignment: .trailing, spacing: 2) {
                    Text("HIGH SCORE")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(.gray)
                    
                    Text("\(highScore) / 5")
                        .font(.system(.subheadline, design: .monospaced).bold())
                        .foregroundStyle(level.themeColor)
                }
            }
            .padding(16)
            .background(Color(white: 0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(level.themeColor.opacity(highScore > 0 ? 0.35 : 0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
