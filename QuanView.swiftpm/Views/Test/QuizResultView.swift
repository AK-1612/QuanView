import SwiftUI

struct QuizResultView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(white: 0.035).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Achievement Medal
                ZStack {
                    Circle()
                        .fill(viewModel.selectedLevel?.themeColor.opacity(0.12) ?? .cyan.opacity(0.12))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "award.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(viewModel.selectedLevel?.themeColor ?? .cyan)
                }
                
                // Score text
                VStack(spacing: 8) {
                    Text("TEST COMPLETE")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(viewModel.selectedLevel?.themeColor ?? .cyan)
                        .tracking(3)
                    
                    Text("\(viewModel.correctCount) / \(viewModel.activeQuestions.count)")
                        .font(.system(size: 48, weight: .black, design: .monospaced))
                        .foregroundStyle(.white)
                    
                    Text("Accuracy: \(Int(Double(viewModel.correctCount) / Double(viewModel.activeQuestions.count) * 100))%")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                
                // Feedback badge card
                VStack(spacing: 6) {
                    Text(rankTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Text(rankDescription)
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(16)
                .background(Color(white: 0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.selectedLevel?.themeColor.opacity(0.15) ?? .cyan.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Done Button
                Button(action: {
                    viewModel.reset()
                    dismiss()
                }) {
                    Text("Return to Hub")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundStyle(.black)
                        .background(viewModel.selectedLevel?.themeColor ?? .cyan)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var rankTitle: String {
        let pct = Double(viewModel.correctCount) / Double(viewModel.activeQuestions.count)
        if pct >= 1.0 {
            return "Quantum Singularity"
        } else if pct >= 0.8 {
            return "Coherence Master"
        } else if pct >= 0.6 {
            return "Schrödinger's Apprentice"
        } else {
            return "Decohered Observer"
        }
    }
    
    private var rankDescription: String {
        let pct = Double(viewModel.correctCount) / Double(viewModel.activeQuestions.count)
        if pct >= 1.0 {
            return "Perfect score! You have achieved complete superposition resonance across all equations."
        } else if pct >= 0.8 {
            return "Excellent job. Your quantum state correlations are highly coherent and robust."
        } else if pct >= 0.6 {
            return "Good progress. Keep observing the labs to further reduce your uncertainty principal."
        } else {
            return "The environment caused decoherence. Re-run the modules to stabilize your understanding."
        }
    }
}
