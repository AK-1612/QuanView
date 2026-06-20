import Foundation
import SwiftUI
import Combine

@MainActor
class QuizViewModel: ObservableObject {
    @Published var selectedLevel: QuizLevel? = nil
    @Published var activeQuestions: [QuizQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswerIndex: Int? = nil
    @Published var isAnswered = false
    @Published var correctCount = 0
    @Published var quizFinished = false
    
    // High scores dictionary: [LevelName: Score]
    @Published var highScores: [String: Int] = [:] {
        didSet {
            UserDefaults.standard.set(highScores, forKey: "QuanView.QuizHighScores")
        }
    }
    
    init() {
        if let saved = UserDefaults.standard.dictionary(forKey: "QuanView.QuizHighScores") as? [String: Int] {
            self.highScores = saved
        }
    }
    
    func startQuiz(level: QuizLevel) {
        selectedLevel = level
        // Fetch questions for this level and shuffle them, pick up to 5 for a quick/engaging test
        let allForLevel = QuizQuestion.database.filter { $0.level == level }
        activeQuestions = Array(allForLevel.shuffled().prefix(5))
        currentQuestionIndex = 0
        selectedAnswerIndex = nil
        isAnswered = false
        correctCount = 0
        quizFinished = false
    }
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < activeQuestions.count else { return nil }
        return activeQuestions[currentQuestionIndex]
    }
    
    func selectAnswer(index: Int) {
        guard !isAnswered else { return }
        selectedAnswerIndex = index
        isAnswered = true
        
        if let question = currentQuestion, index == question.correctIndex {
            correctCount += 1
        }
    }
    
    func nextQuestion() {
        guard isAnswered else { return }
        if currentQuestionIndex < activeQuestions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
            isAnswered = false
        } else {
            finishQuiz()
        }
    }
    
    private func finishQuiz() {
        quizFinished = true
        if let level = selectedLevel {
            let key = level.rawValue
            let existing = highScores[key] ?? 0
            if correctCount > existing {
                highScores[key] = correctCount
            }
        }
    }
    
    func reset() {
        selectedLevel = nil
        activeQuestions = []
        currentQuestionIndex = 0
        selectedAnswerIndex = nil
        isAnswered = false
        correctCount = 0
        quizFinished = false
    }
}
