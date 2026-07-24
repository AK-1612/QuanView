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
                    description: "By rotating the tesseract along a plane involving the 4th spatial coordinate (W-axis), its 3D projection appears to twist, expand, and fold through itself.",
                    badge: "STEP 2: W-PLANE ROTATION"
                ),
                LessonSlide(
                    title: "Zero-Point Energy Metaphor",
                    description: "In quantum field theory, space is never truly empty. We use the hypercube as a geometric metaphor for zero-point vacuum energy fluctuations.",
                    badge: "STEP 3: QUANTUM VACUUM"
                )
            ]
        case .tunneling:
            return [
                LessonSlide(
                    title: "Classical Energy Barrier",
                    description: "Classically, a particle with energy E < V₀ can never pass through a potential barrier V₀. It gets reflected 100% of the time.",
                    badge: "STEP 1: CLASSICAL BOUNDARY"
                ),
                LessonSlide(
                    title: "Wavefunction Decay",
                    description: "In quantum mechanics, the particle's wavefunction exponentially decays inside the barrier ψ(x) ~ e^(-κx), but retains a non-zero amplitude.",
                    badge: "STEP 2: EXPONENTIAL PENETRATION"
                ),
                LessonSlide(
                    title: "Transmission Probability",
                    description: "If the barrier width L is thin enough, a transmitted wave packet emerges on the other side with probability T ≈ exp(-2κL).",
                    badge: "STEP 3: TUNNELING EMERGENCE"
                )
            ]
        case .sternGerlach:
            return [
                LessonSlide(
                    title: "The Inhomogeneous Field",
                    description: "Silver atoms pass through a custom magnetic field gradient ∇B where force depends on intrinsic angular momentum.",
                    badge: "STEP 1: MAGNETIC GRADIENT"
                ),
                LessonSlide(
                    title: "Classical Expectation vs Reality",
                    description: "Classical physics predicted a continuous smear of deflection. Instead, the beam splits cleanly into two discrete paths.",
                    badge: "STEP 2: DISCRETE BEAM SPLIT"
                ),
                LessonSlide(
                    title: "Quantized Spin ±1/2",
                    description: "This proved space quantization: spin angular momentum is quantized into discrete ms = +1/2 (up) and ms = -1/2 (down) states.",
                    badge: "STEP 3: SPIN QUANTIZATION"
                )
            ]
        case .teleportation:
            return [
                LessonSlide(
                    title: "Shared EPR Pair",
                    description: "Alice and Bob start by sharing a pair of entangled particles. Alice also holds an unknown qubit state |Ψ⟩ to transfer.",
                    badge: "STEP 1: ENTANGLED RESOURCE"
                ),
                LessonSlide(
                    title: "Bell-State Measurement",
                    description: "Alice performs a joint Bell-state measurement on her qubit and entangled particle, sending 2 classical bits to Bob.",
                    badge: "STEP 2: JOINT MEASUREMENT"
                ),
                LessonSlide(
                    title: "State Reconstruction",
                    description: "Bob applies one of 4 Pauli operations based on Alice's classical bits to reconstruct |Ψ⟩ perfectly. The original is destroyed.",
                    badge: "STEP 3: PERFECT RECONSTRUCTION"
                )
            ]
        case .superconductivity:
            return [
                LessonSlide(
                    title: "Cooper Pair Condensation",
                    description: "Below critical temperature Tc, electrons form Cooper pairs mediated by lattice vibrations, condensing into a single quantum state.",
                    badge: "STEP 1: COOPER PAIR CONDENSATE"
                ),
                LessonSlide(
                    title: "Meissner Flux Expulsion",
                    description: "Surface supercurrents arise to generate an opposing magnetic field, expelling external magnetic flux lines B = 0 from the interior.",
                    badge: "STEP 2: MEISSNER EXPULSION"
                ),
                LessonSlide(
                    title: "Quantum Flux Pinning",
                    description: "Magnetic flux tubes become pinned in defects inside Type-II superconductors, trapping the magnet in stable levitation.",
                    badge: "STEP 3: STABLE LEVITATION"
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
