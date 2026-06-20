import Foundation
import SwiftUI
import Combine

struct LessonSlide: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let badge: String
}

@MainActor
class LessonViewModel: ObservableObject {
    let concept: QuantumConcept
    
    @Published var currentSlideIndex = 0
    @Published var isAnimating = true
    @Published var resetView = false
    @Published var zoomCommand = 0
    @Published var interactionCommand = 0
    
    var slides: [LessonSlide] {
        switch concept {
        case .superposition:
            return [
                LessonSlide(
                    title: "Classical Orbit vs. Probability",
                    description: "In classical physics, we imagine electrons orbiting a nucleus like planets around a star. In quantum mechanics, however, a particle does not have a single position; it exists as a wave of probability amplitudes.",
                    badge: "STEP 1: THEbaseline"
                ),
                LessonSlide(
                    title: "The Superposition Cloud",
                    description: "The electron is in a superposition of all possible locations simultaneously. The shape of this probability cloud is determined by its wave function equations. It has not chosen a single position yet.",
                    badge: "STEP 2: SUPERPOSITION"
                ),
                LessonSlide(
                    title: "Wavefunction Collapse",
                    description: "When the system interacts with an observer or measuring device, the wavefunction instantly collapses. The probability cloud vanishes, and the particle is detected at one specific, localized point.",
                    badge: "STEP 3: MEASUREMENT"
                )
            ]
        case .waveParticle:
            return [
                LessonSlide(
                    title: "The Slit Barrier",
                    description: "To study matter-wave duality, we shoot quantum entities (like photons or electrons) through a barrier with two narrow slits towards a screen.",
                    badge: "STEP 1: THE PHYSICAL SETUP"
                ),
                LessonSlide(
                    title: "Wavefront Propagation",
                    description: "Before hitting the detector, the particle behaves like a wave. The probability wave passes through both slits simultaneously, creating wavefronts that interfere with one another.",
                    badge: "STEP 2: WAVE INTERFERENCE"
                ),
                LessonSlide(
                    title: "Fringe Pattern Detection",
                    description: "Upon striking the screen, the wave collapses into individual particle impacts. Over time, these discrete dots accumulate to form a continuous interference pattern of light and dark bands.",
                    badge: "STEP 3: PARTICLE COLLAPSE"
                )
            ]
        case .entanglement:
            return [
                LessonSlide(
                    title: "Entangled Pair Creation",
                    description: "When two particles interact closely, they can form a shared, inseparable quantum state. Their individual states (such as spin direction) are completely undetermined, yet perfectly correlated.",
                    badge: "STEP 1: COHERENT SOURCE"
                ),
                LessonSlide(
                    title: "Spatial Separation",
                    description: "Even if these particles travel to opposite sides of the universe, their entanglement persists. A measurement of one will instantly influence the state of the other, exceeding classical communication limits.",
                    badge: "STEP 2: EPR DISTANCE"
                ),
                LessonSlide(
                    title: "Synchronous Collapse",
                    description: "Measuring Particle A collapses its wavefunction. If we find it is 'spin-up', Particle B immediately collapses into the correlated 'spin-down' state. This non-local correlation violates classical physics.",
                    badge: "STEP 3: BELL STATE COLLAPSE"
                )
            ]
        case .tesseract:
            return [
                LessonSlide(
                    title: "The 3D Shadow of 4D",
                    description: "A tesseract is a 4-dimensional hypercube. Just as a 3D cube casts a 2D shadow on a flat surface, the 3D tesseract you see is a shadow projection of a 4-dimensional object in Euclidean space.",
                    badge: "STEP 1: HYPERDIMENSIONS"
                ),
                LessonSlide(
                    title: "Rotation in the W-Axis",
                    description: "By rotating the tesseract along a plane involving the 4th spatial coordinate (W-axis), its 3D projection appears to twist, expand, and fold through itself. The vertices are not actually changing size; it is just a rotational perspective.",
                    badge: "STEP 2: W-PLANE ROTATION"
                ),
                LessonSlide(
                    title: "Zero-Point Energy Métaphore",
                    description: "In quantum field theory, space is never truly empty; vacuum fluctuations occur constantly. We use the expanding/contracting hypercube as a metaphor for these higher-dimensional energy oscillations.",
                    badge: "STEP 3: QUANTUM VACUUM"
                )
            ]
        }
    }
    
    init(concept: QuantumConcept) {
        self.concept = concept
    }
    
    var isFirstSlide: Bool {
        currentSlideIndex == 0
    }
    
    var isLastSlide: Bool {
        currentSlideIndex == slides.count - 1
    }
    
    func nextSlide() {
        if currentSlideIndex < slides.count - 1 {
            currentSlideIndex += 1
            triggerInteraction()
        }
    }
    
    func previousSlide() {
        if currentSlideIndex > 0 {
            currentSlideIndex -= 1
            triggerInteraction()
        }
    }
    
    private func triggerInteraction() {
        interactionCommand += 1
    }
}
