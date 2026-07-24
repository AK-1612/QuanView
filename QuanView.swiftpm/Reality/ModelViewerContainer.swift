import SwiftUI

@MainActor
struct ModelViewerContainer: View {
    let concept: QuantumConcept
    @Binding var isAnimating: Bool
    @Binding var resetView: Bool
    @Binding var zoomCommand: Int
    @Binding var interactionCommand: Int
    var slideIndex: Int = -1
    
    var body: some View {
        SceneKitContainer(
            concept: concept,
            isAnimating: $isAnimating,
            resetView: $resetView,
            zoomCommand: $zoomCommand,
            interactionCommand: $interactionCommand,
            slideIndex: slideIndex
        )
    }
}
