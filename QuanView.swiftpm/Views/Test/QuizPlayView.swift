import SwiftUI

struct QuizPlayView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.dismiss) var dismiss
    
    // Auxiliary state for 3D viewer inside quiz
    @State private var isAnimating = true
    @State private var resetView = false
    @State private var zoomCommand = 0
    @State private var interactionCommand = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.035).ignoresSafeArea()
                
                if viewModel.quizFinished {
                    QuizResultView(viewModel: viewModel)
                } else if let question = viewModel.currentQuestion {
                    VStack(spacing: 0) {
                        // Progress Bar
                        ProgressView(value: Double(viewModel.currentQuestionIndex + 1), total: Double(viewModel.activeQuestions.count))
                            .tint(viewModel.selectedLevel?.themeColor ?? .cyan)
                            .padding(.top, 4)
                        
                        // 3D Visualizer Context
                        ModelViewerContainer(
                            concept: question.concept,
                            isAnimating: $isAnimating,
                            resetView: $resetView,
                            zoomCommand: $zoomCommand,
                            interactionCommand: $interactionCommand,
                            slideIndex: -1
                        )
                        .frame(height: UIScreen.main.bounds.height * 0.3)
                        .background(Color(white: 0.02))
                        
                        // Question content
                        VStack(alignment: .leading, spacing: 16) {
                            // Question Text
                            Text(question.questionText)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 16)
                                .padding(.top, 14)
                            
                            // Options List
                            ScrollView {
                                VStack(spacing: 10) {
                                    ForEach(0..<question.options.count, id: \.self) { idx in
                                        OptionButton(
                                            optionText: question.options[idx],
                                            isSelected: viewModel.selectedAnswerIndex == idx,
                                            isCorrect: question.correctIndex == idx,
                                            isAnswered: viewModel.isAnswered,
                                            themeColor: viewModel.selectedLevel?.themeColor ?? .cyan,
                                            action: {
                                                viewModel.selectAnswer(index: idx)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            
                            // Explanation / Navigation
                            if viewModel.isAnswered {
                                explanationPanel(question: question)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(Color(white: 0.055))
                    }
                }
            }
            .navigationTitle("\(viewModel.selectedLevel?.rawValue ?? "") Test (\(viewModel.currentQuestionIndex + 1)/\(viewModel.activeQuestions.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Exit") {
                        viewModel.reset()
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            }
        }
    }
    
    @ViewBuilder
    func explanationPanel(question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EXPLANATION")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(viewModel.selectedLevel?.themeColor ?? .cyan)
            
            Text(question.explanation)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(3)
            
            Button(action: {
                viewModel.nextQuestion()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }) {
                HStack {
                    Spacer()
                    Text(viewModel.currentQuestionIndex < viewModel.activeQuestions.count - 1 ? "Next Question" : "Finish Test")
                        .font(.system(size: 14, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                }
                .frame(height: 46)
                .foregroundStyle(.black)
                .background(viewModel.selectedLevel?.themeColor ?? .cyan)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}

struct OptionButton: View {
    let optionText: String
    let isSelected: Bool
    let isCorrect: Bool
    let isAnswered: Bool
    let themeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(optionText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Spacer()
                
                if isAnswered {
                    Image(systemName: indicatorIcon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(indicatorColor)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .disabled(isAnswered)
    }
    
    private var textColor: Color {
        if !isAnswered { return .white }
        if isCorrect { return .green }
        if isSelected { return .red }
        return .white.opacity(0.4)
    }
    
    private var backgroundColor: Color {
        if !isAnswered { return Color(white: 0.1) }
        if isCorrect { return Color.green.opacity(0.12) }
        if isSelected { return Color.red.opacity(0.12) }
        return Color(white: 0.08)
    }
    
    private var borderColor: Color {
        if !isAnswered { return Color.white.opacity(0.08) }
        if isCorrect { return Color.green.opacity(0.4) }
        if isSelected { return Color.red.opacity(0.4) }
        return Color.clear
    }
    
    private var indicatorIcon: String {
        if isCorrect { return "checkmark.circle.fill" }
        if isSelected { return "xmark.circle.fill" }
        return ""
    }
    
    private var indicatorColor: Color {
        if isCorrect { return .green }
        if isSelected { return .red }
        return .clear
    }
}
