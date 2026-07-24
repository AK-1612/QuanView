import Foundation
import SwiftUI
import Combine

@MainActor
class SandboxViewModel: ObservableObject {
    let concept: QuantumConcept
    
    // Core visualization toggles
    @Published var mode: String = "Room" // "Room" or "AR"
    @Published var isAnimating = true
    @Published var resetView = false
    @Published var zoomCommand = 0
    @Published var interactionCommand = 0
    
    // AR States
    @Published var executeSimulation = false
    @Published var resetSimulation = false
    @Published var capturePhoto = false
    @Published var isModelPlaced = false
    @Published var physicsIntensity: Float = 1.0
    @Published var capturedImage: UIImage? = nil
    
    // Concept-specific Sandbox Parameters (Interactive Sliders)
    @Published var orbitalN: Int = 2 // Hydrogen orbital shell
    @Published var slitDistance: Float = 0.05 // Slit separation d
    @Published var polarizationAngle: Float = 0.0 // Entangled spin filter angle
    @Published var rotationSpeed4D: Float = 1.0 // Tesseract rotation speed
    @Published var barrierHeight: Float = 1.5 // Tunneling potential barrier V0
    @Published var magneticGradient: Float = 2.0 // Stern-Gerlach field gradient dB/dz
    @Published var bellStateIndex: Int = 0 // Quantum teleportation Bell pair state
    @Published var criticalTemperature: Float = 77.0 // Superconducting temp (K)
    
    init(concept: QuantumConcept) {
        self.concept = concept
    }
    
    func resetSandbox() {
        resetView = true
        resetSimulation = true
        isModelPlaced = false
        interactionCommand = 0
        orbitalN = 2
        slitDistance = 0.05
        polarizationAngle = 0.0
        rotationSpeed4D = 1.0
        barrierHeight = 1.5
        magneticGradient = 2.0
        bellStateIndex = 0
        criticalTemperature = 77.0
    }
}
