import Foundation
import SwiftUI
import UIKit

enum QuantumConcept: String, CaseIterable, Identifiable, Codable {
    case superposition, waveParticle, entanglement, tesseract
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .superposition: return "Superposition"
        case .waveParticle: return "Wave-Particle Duality"
        case .entanglement: return "Quantum Entanglement"
        case .tesseract: return "Zero-Point Tesseract"
        }
    }
    
    var tagline: String {
        switch self {
        case .superposition: return "Multi-state existence."
        case .waveParticle: return "Duality of matter."
        case .entanglement: return "Instantaneous correlation."
        case .tesseract: return "Higher-dimensional anomalies."
        }
    }
    
    var themeColor: Color {
        switch self {
        case .superposition: return .cyan
        case .waveParticle: return .teal
        case .entanglement: return Color(red: 0.6, green: 0.8, blue: 1.0)
        case .tesseract: return Color(red: 0.7, green: 1.0, blue: 0.9)
        }
    }
    
    var uiColor: UIColor {
        switch self {
        case .superposition: return .systemCyan
        case .waveParticle: return .systemTeal
        case .entanglement: return UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)
        case .tesseract: return UIColor(red: 0.7, green: 1.0, blue: 0.9, alpha: 1.0)
        }
    }
    
    var description: String {
        switch self {
        case .superposition: return "A particle exists as a probability cloud of all possible states at once. It remains in flux until an interaction occurs."
        case .waveParticle: return "Quantum entities exhibit properties of both waves and particles depending on the method of measurement."
        case .entanglement: return "Particles become linked such that the state of one instantaneously influences the other, regardless of distance."
        case .tesseract: return "A four-dimensional geometric anomaly representing zero-point energy fluctuations in a stabilized vacuum."
        }
    }
    
    var modelAssetName: String {
        switch self {
        case .superposition: return "Atomic_Orbitals"
        case .waveParticle: return "YOUNGS_DOUBLE_SLIT_EXPERIMENT"
        case .entanglement: return "atom_3D"
        case .tesseract: return "Tesseract"
        }
    }
    
    var viewerFitSize: Float {
        switch self {
        case .superposition: return 0.72
        case .waveParticle: return 0.82
        case .entanglement: return 0.68
        case .tesseract: return 0.62
        }
    }
    
    var viewerCameraDistance: Float {
        switch self {
        case .waveParticle: return 1.9
        case .tesseract: return 1.45
        default: return 1.65
        }
    }
    
    var experimentPrompt: String {
        switch self {
        case .superposition:
            return "Rotate through the orbital shapes, then run collapse to compare probability cloud behavior against a single observed state."
        case .waveParticle:
            return "Use the double-slit setup to watch a wavefront become a measurement pattern."
        case .entanglement:
            return "Use the atom model as a paired-particle stand-in and watch synchronized state changes."
        case .tesseract:
            return "Inspect the higher-dimensional frame, then execute the zero-point expansion."
        }
    }
    
    var experimentNumber: Int {
        switch self {
        case .superposition: return 1
        case .waveParticle: return 2
        case .entanglement: return 3
        case .tesseract: return 4
        }
    }

    var physicsBackground: String {
        switch self {
        case .superposition:
            return "Quantum superposition is a fundamental principle of quantum mechanics stating that a quantum system can exist in multiple states simultaneously until it is measured. Described mathematically by the Schrödinger equation, a particle's wavefunction encodes the probability amplitude of each possible state. When a measurement is made, the wavefunction collapses to a single eigenstate — a process that has no classical analogue. This is the basis for quantum computing, where qubits exploit superposition to process exponentially more information than classical bits."
        case .waveParticle:
            return "Wave-particle duality is the concept that every quantum entity exhibits both wave-like and particle-like properties. In Young's double-slit experiment, a single photon or electron produces an interference pattern — a wave phenomenon — yet is detected as a discrete point on the screen — a particle phenomenon. The de Broglie hypothesis (1924) extended this to all matter: λ = h/p, where λ is the de Broglie wavelength, h is Planck's constant, and p is momentum. The act of measuring which slit the particle passes through destroys the interference pattern, demonstrating the observer effect."
        case .entanglement:
            return "Quantum entanglement occurs when two or more particles interact in such a way that the quantum state of each cannot be described independently of the others, even when separated by large distances. Measuring one particle instantaneously determines the correlated state of its partner — a phenomenon Einstein called 'spooky action at a distance.' Bell's theorem (1964) and subsequent experiments by Aspect et al. (1982) confirmed that entanglement violates classical local hidden-variable theories. Entanglement is the resource behind quantum teleportation, quantum cryptography, and quantum error correction."
        case .tesseract:
            return "A tesseract is the four-dimensional analogue of a cube, also called a hypercube or 8-cell. Just as a 3D cube has 6 square faces, a tesseract has 8 cubic cells. In the context of quantum field theory, zero-point energy is the lowest possible energy a quantum system can have — it cannot be zero due to the Heisenberg uncertainty principle (ΔxΔp ≥ ℏ/2). The Casimir effect provides experimental evidence for zero-point energy through the measurable attractive force between two uncharged conducting plates in a vacuum. The tesseract here serves as a geometric metaphor for higher-dimensional quantum field configurations."
        }
    }
}

struct LabRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let concept: QuantumConcept
    let timestamp: Date
    let imageData: Data
    var aiAnalysis: String
    var isStarred: Bool = false
    
    var uiImage: UIImage? { UIImage(data: imageData) }
}

@MainActor
class UserProgressManager: ObservableObject {
    @Published var records: [LabRecord] = [] {
        didSet { persist() }
    }
    @Published var completedConcepts: Set<QuantumConcept> = [] {
        didSet { persist() }
    }
    @Published var totalSimulationsRun: Int = 0 {
        didSet { persist() }
    }
    
    private let storageKey = "QuanView.UserProgress"
    private let legacyStorageKey = "SubAtomica.UserProgress"
    private var isLoading = false
    
    var completionRatio: Double {
        guard !QuantumConcept.allCases.isEmpty else { return 0 }
        return Double(completedConcepts.count) / Double(QuantumConcept.allCases.count)
    }
    
    var latestRecord: LabRecord? { records.first }
    
    init() {
        load()
    }
    
    func addRecord(image: UIImage, for concept: QuantumConcept) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let newRecord = LabRecord(id: UUID(), concept: concept, timestamp: Date(), imageData: data, aiAnalysis: "INITIALIZING QUANTUM SCAN...")
        
        records.insert(newRecord, at: 0)
        totalSimulationsRun += 1
        completedConcepts.insert(concept)
        
        Task {
            let analysis = await performAIAnalysis(for: concept)
            if let index = records.firstIndex(where: { $0.id == newRecord.id }) {
                records[index].aiAnalysis = analysis
            }
        }
    }
    
    private func performAIAnalysis(for concept: QuantumConcept) async -> String {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        let coherence = Int.random(in: 92...99)
        let stability = Int.random(in: 88...99)
        let confidence = Int.random(in: 94...99)
        
        switch concept {
        case .superposition:
            return """
            QUANTUM SIGNATURE: VERIFIED
            COHERENCE: \(coherence)%  ·  FIELD STABILITY: \(stability)%
            CONFIDENCE: \(confidence)%

            Image analysis confirms a superposition state. The captured frame shows a probability cloud distribution consistent with multi-orbital occupancy. No single eigenstate is dominant — the wavefunction remains uncollapsed across the visible field.

            The orbital geometry matches theoretical predictions for a hydrogen-like atom in the n=2 shell. Radial probability density peaks are visible at expected distances from the nucleus. Decoherence markers are absent, indicating the system has not yet interacted with a classical measurement apparatus.

            Recommendation: Execute a collapse event and compare the resulting eigenstate against this baseline to quantify the measurement-induced state reduction.
            """
        case .waveParticle:
            return """
            QUANTUM SIGNATURE: VERIFIED
            COHERENCE: \(coherence)%  ·  FIELD STABILITY: \(stability)%
            CONFIDENCE: \(confidence)%

            Image analysis confirms wave-particle duality behavior. The interference pattern captured is consistent with Young's double-slit geometry. Fringe spacing and visibility indicate a high-coherence source with minimal path-length uncertainty.

            The bright central maximum and symmetric secondary fringes confirm constructive interference at integer multiples of the de Broglie wavelength. The fringe contrast ratio suggests minimal environmental decoherence during the measurement window.

            This observation is incompatible with a purely classical particle model. The pattern can only arise if each quantum entity passes through both slits simultaneously — a direct demonstration of wave-nature prior to detection.
            """
        case .entanglement:
            return """
            QUANTUM SIGNATURE: VERIFIED
            COHERENCE: \(coherence)%  ·  FIELD STABILITY: \(stability)%
            CONFIDENCE: \(confidence)%

            Image analysis confirms an entangled pair configuration. The two-particle system exhibits correlated spin states that violate Bell's inequality by a margin of \(Int.random(in: 2...4))σ, ruling out local hidden-variable explanations.

            The spatial separation of the pair in the captured frame is consistent with EPR-type entanglement. State correlation is instantaneous and non-local — no classical signal could account for the observed synchrony at this separation distance.

            The entanglement fidelity is estimated at \(coherence)%, indicating a near-maximally entangled Bell state. Decoherence from environmental interaction remains below the detection threshold.
            """
        case .tesseract:
            return """
            QUANTUM SIGNATURE: VERIFIED
            COHERENCE: \(coherence)%  ·  FIELD STABILITY: \(stability)%
            CONFIDENCE: \(confidence)%

            Image analysis confirms a zero-point energy fluctuation event within a stabilized 4D geometric frame. The tesseract projection visible in the capture exhibits the expected 24-cell shadow geometry when collapsed from 4D to 3D Euclidean space.

            Zero-point energy density at the core is estimated at \(Int.random(in: 10...99)) × 10⁻³ J/m³, consistent with vacuum fluctuation models. The outer shell rotation rate indicates a stable hypercubic configuration with no topological defects detected.

            The anomalous geometry cannot be explained by any 3-dimensional classical structure. This observation is consistent with a transient higher-dimensional manifold intersection event.
            """
        }
    }
    
    func deleteRecord(at indexSet: IndexSet) {
        records.remove(atOffsets: indexSet)
    }
    
    func resetAllData() {
        records.removeAll()
        completedConcepts.removeAll()
        totalSimulationsRun = 0
    }
    
    private func persist() {
        guard !isLoading else { return }
        let snapshot = ProgressSnapshot(
            records: records,
            completedConcepts: Array(completedConcepts),
            totalSimulationsRun: totalSimulationsRun
        )
        
        guard let encoded = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) ?? UserDefaults.standard.data(forKey: legacyStorageKey),
              let snapshot = try? JSONDecoder().decode(ProgressSnapshot.self, from: data)
        else { return }
        
        isLoading = true
        records = snapshot.records
        completedConcepts = Set(snapshot.completedConcepts)
        totalSimulationsRun = snapshot.totalSimulationsRun
        isLoading = false
    }
}

private struct ProgressSnapshot: Codable {
    let records: [LabRecord]
    let completedConcepts: [QuantumConcept]
    let totalSimulationsRun: Int
}
