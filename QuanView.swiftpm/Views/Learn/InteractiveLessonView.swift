import SwiftUI

struct InteractiveLessonView: View {
    let concept: QuantumConcept
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var progressManager: UserProgressManager
    @StateObject private var viewModel: LessonViewModel
    
    init(concept: QuantumConcept) {
        self.concept = concept
        self._viewModel = StateObject(wrappedValue: LessonViewModel(concept: concept))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top: 3D Scene View
            ZStack(alignment: .topTrailing) {
                ModelViewerContainer(
                    concept: concept,
                    isAnimating: $viewModel.isAnimating,
                    resetView: $viewModel.resetView,
                    zoomCommand: $viewModel.zoomCommand,
                    interactionCommand: $viewModel.interactionCommand,
                    slideIndex: viewModel.currentSlideIndex
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)
                
                // Instructions floating badge
                Text(viewModel.slides[viewModel.currentSlideIndex].badge)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(concept.themeColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Capsule())
                    .padding(16)
            }
            .frame(height: UIScreen.main.bounds.height * 0.44)
            .background(Color(white: 0.02))
            
            // Bottom: Lesson Cards and Steps Navigation
            VStack(spacing: 0) {
                // Card contents
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.slides[viewModel.currentSlideIndex].title)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    
                    ScrollView {
                        Text(viewModel.slides[viewModel.currentSlideIndex].description)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.8))
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color(white: 0.06))
                
                Divider().background(Color.white.opacity(0.1))
                
                // Step controls
                HStack {
                    // Back
                    Button(action: {
                        viewModel.previousSlide()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Label("Back", systemImage: "arrow.left")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(viewModel.isFirstSlide)
                    .opacity(viewModel.isFirstSlide ? 0.4 : 1)
                    
                    Spacer()
                    
                    // Slide Indicators
                    HStack(spacing: 6) {
                        ForEach(0..<viewModel.slides.count, id: \.self) { idx in
                            Circle()
                                .fill(idx == viewModel.currentSlideIndex ? concept.themeColor : Color.white.opacity(0.2))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    // Next / Finish
                    Button(action: {
                        if viewModel.isLastSlide {
                            progressManager.completedConcepts.insert(concept)
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            dismiss()
                        } else {
                            viewModel.nextSlide()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }) {
                        HStack {
                            Text(viewModel.isLastSlide ? "Complete" : "Next")
                            Image(systemName: viewModel.isLastSlide ? "checkmark.circle.fill" : "arrow.right")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(concept.themeColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(16)
                .background(Color(white: 0.08))
            }
            .frame(height: UIScreen.main.bounds.height * 0.38)
        }
        .background(Color(white: 0.035).ignoresSafeArea())
        .navigationTitle("Lesson: \(concept.title)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
