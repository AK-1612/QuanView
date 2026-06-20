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

// MARK: - Quiz Data Structures

enum QuizLevel: String, CaseIterable, Identifiable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .beginner: return "Fundamental quantum concepts & states"
        case .intermediate: return "Superposition collapses & wave behaviors"
        case .advanced: return "Math-heavy Bell's tests & 4D manifolds"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .beginner: return .cyan
        case .intermediate: return .teal
        case .advanced: return Color(red: 0.7, green: 0.8, blue: 1.0)
        }
    }
}

struct QuizQuestion: Identifiable, Codable, Hashable {
    let id: UUID
    let questionText: String
    let options: [String]
    let correctIndex: Int
    let level: QuizLevel
    let concept: QuantumConcept
    let explanation: String
}

// MARK: - Directory Data Structures

enum DirectoryCategory: String, CaseIterable, Identifiable, Codable {
    case particle = "Subatomic Particles"
    case equation = "Core Equations"
    var id: String { rawValue }
}

struct DirectoryItem: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let category: DirectoryCategory
    let symbol: String
    let subtitle: String
    let properties: [String: String] // e.g. ["Mass": "0", "Spin": "1"]
    let explanation: String
    let application: String
    let concept: QuantumConcept // Used to tie back to the 3D viewer model
}

// MARK: - Static Datasets

extension QuizQuestion {
    static let database: [QuizQuestion] = [
        // MARK: Beginner
        QuizQuestion(
            id: UUID(),
            questionText: "What does quantum superposition state about a particle?",
            options: [
                "It exists in exactly one state at all times.",
                "It exists in multiple states simultaneously until measured.",
                "It travels faster than light.",
                "It is always stationary in space."
            ],
            correctIndex: 1,
            level: .beginner,
            concept: .superposition,
            explanation: "Superposition states that a physical system remains in multiple potential states concurrently. Only during interaction or observation does it reduce to a single classical state."
        ),
        QuizQuestion(
            id: UUID(),
            questionText: "Which experiment proved that light behaves as both waves and particles?",
            options: [
                "Michelson-Morley Experiment",
                "Rutherford Gold Foil Experiment",
                "Young's Double-Slit Experiment",
                "Stern-Gerlach Experiment"
            ],
            correctIndex: 2,
            level: .beginner,
            concept: .waveParticle,
            explanation: "Young's Double-Slit experiment showed that firing individual particles (like photons or electrons) through two slits creates an interference pattern over time, confirming wave-particle duality."
        ),
        QuizQuestion(
            id: UUID(),
            questionText: "What does the term 'Entanglement' represent?",
            options: [
                "Particles colliding and merging together",
                "Magnetic fields pulling objects together",
                "Quantum state correlation that exists instantaneously regardless of separation",
                "Gravitational orbits of quantum systems"
            ],
            correctIndex: 2,
            level: .beginner,
            concept: .entanglement,
            explanation: "Entanglement occurs when particles become linked so that measuring the state of one immediately determines the state of the other, even if separated by light-years."
        ),
        QuizQuestion(
            id: UUID(),
            questionText: "How many cubic cells form the boundaries of a 4D Tesseract?",
            options: ["4 cells", "6 cells", "8 cells", "16 cells"],
            correctIndex: 2,
            level: .beginner,
            concept: .tesseract,
            explanation: "A tesseract is the 4D hypercube analogue of a 3D cube. It is bounded by 8 cubic cells, just as a 3D cube is bounded by 6 square faces."
        ),
        QuizQuestion(
            id: UUID(),
            questionText: "In quantum mechanics, what causes a wavefunction to collapse?",
            options: [
                "An increase in temperature",
                "A measurement or observation event",
                "Decay of the nucleus",
                "Gravitational collapse"
            ],
            correctIndex: 1,
            level: .beginner,
            concept: .superposition,
            explanation: "The act of measurement forces a quantum system out of superposition, collapsing the wave function into a single definite state."
        ),
        
        // MARK: Intermediate
        QuizQuestion(
            id: UUID(),
            questionText: "According to the de Broglie relation, how are wavelength (λ) and momentum (p) related?",
            options: [
                "λ is proportional to p",
                "λ is inversely proportional to p",
                "λ is independent of p",
                "λ is proportional to p squared"
            ],
            correctIndex: 1,
            level: .intermediate,
            concept: .waveParticle,
            explanation: "The de Broglie relation is λ = h / p, meaning wavelength is inversely proportional to momentum. Larger objects with high momentum have wavelengths too small to observe."
        ),
        QuizQuestion(
            id: UUID(),
            questionText: "In an EPR pair measurement, if photon A is measured to be spin-up, what is photon B's state if they are anti-correlated?",
            options: [
                "Spin-up",
                "Spin-down",
                "Superposition",
                "Undetermined until B is measured"
            ],
            correctIndex: 1,
            level: .intermediate,
            concept: .entanglement,
            explanation: "If the entangled pair is anti-correlated (like a singlet state), measuring one as spin-up immediately forces the other to collapse into the spin-down state."
        ),
        QuizQuestion(
            id: UUID(),
            questionText: "What does the outer boundaries of a tesseract look like when projected into 3-dimensional space?",
            options: [
                "A sphere nested in a cone",
                "A cube nested inside another cube with connected vertices",
                "A series of interlocking pyramids",
                "A flat hexagon shape"
            ],
            correctIndex: 1,
            level: .intermediate,
            concept: .tesseract,
            explanation: "A perspective projection of a tesseract into 3D space results in a smaller cube centered inside a larger cube, with lines connecting their corresponding corners."
        ),
        QuizQuestion(
            id: UUID(),
            questionText: "What characterizes the n=2, l=1, m=0 orbital of a hydrogen-like atom?",
            options: [
                "A spherical shape (s orbital)",
                "A dumbbell shape aligned along the z-axis (p_z orbital)",
                "A cloverleaf shape in the xy-plane (d_xy orbital)",
                "A ring-torus structure"
            ],
            correctIndex: 1,
            level: .intermediate,
            concept: .superposition,
            explanation: "For angular momentum quantum number l=1, we have p orbitals. The magnetic quantum number m=0 corresponds to the p_z orbital, which is oriented along the z-axis."
        ),
        QuizQuestion(
            id: UUID(),
            questionText: "What happens when you increase the slit distance (d) in the double-slit simulation?",
            options: [
                "Fringes become closer together",
                "Fringes become wider apart",
                "Interference completely disappears",
                "The pattern shifts to a single bright spot"
            ],
            correctIndex: 0,
            level: .intermediate,
            concept: .waveParticle,
            explanation: "The angular spacing of interference fringes is given by θ ≈ λ / d. Increasing the slit distance (d) decreases the fringe spacing, bringing them closer together."
        ),
        
        // MARK: Advanced
        QuizQuestion(
            id: UUID(),
            questionText: "Which inequality establishes that local hidden variables cannot explain quantum correlations?",
            options: [
                "Heisenberg Uncertainty Inequality",
                "Bell's Inequality (CHSH formulation)",
                "Schrödinger Wave Equation",
                "Euler-Lagrange Equation"
            ],
            correctIndex: 1,
            level: .advanced,
            concept: .entanglement,
            explanation: "Bell's theorem states that quantum entanglement violates local realism. The CHSH inequality puts a limit of 2 on classical correlations, whereas quantum mechanics allows up to 2√2 ≈ 2.82."
        ),
        QuizQuestion(
            id: UUID(),
            questionText: "What represents the zero-point energy of a quantum harmonic oscillator?",
            options: ["Zero", "E = (1/2) * h-bar * ω", "E = h-bar * ω", "E = k_B * T"],
            correctIndex: 1,
            level: .advanced,
            concept: .tesseract,
            explanation: "Due to the Heisenberg uncertainty principle, a quantum harmonic oscillator cannot have zero energy at ground state. Its zero-point energy is E = (1/2)ℏω."
        ),
        QuizQuestion(
            id: UUID(),
            questionText: "What mathematical transformation is applied to map a tesseract rotating in the XW plane into 3D?",
            options: [
                "4D rotation matrix followed by a perspective projection matrix",
                "3D orthographic scale followed by translation",
                "Fourier transform of the vertex vectors",
                "Spherical coordinate mapping"
            ],
            correctIndex: 0,
            level: .advanced,
            concept: .tesseract,
            explanation: "We must apply a 4D rotation matrix using trig coordinates for cos(θ) and sin(θ) in the active plane (e.g. XW), then project the 4D points to 3D via perspective division: x_proj = x / (d - w)."
        ),
        QuizQuestion(
            id: UUID(),
            questionText: "What physical quantity does the square of the wavefunction magnitude (|Ψ|²) represent?",
            options: [
                "Energy density",
                "Probability density",
                "Momentum flux",
                "Charge distribution"
            ],
            correctIndex: 1,
            level: .advanced,
            concept: .superposition,
            explanation: "Born's Rule states that |Ψ(x,t)|² yields the probability density of finding a particle at location x at time t."
        ),
        QuizQuestion(
            id: UUID(),
            questionText: "In Bell test experiments, the maximum violation of the CHSH inequality occurs at which angle offset between detector axes?",
            options: ["0 degrees", "22.5 degrees", "45 degrees", "90 degrees"],
            correctIndex: 1,
            level: .advanced,
            concept: .entanglement,
            explanation: "The correlation is proportional to cos(2θ). The maximum quantum violation occurs at θ = 22.5° (and 67.5°), achieving the Tsirelson bound of 2√2."
        )
    ]
}

extension DirectoryItem {
    static let database: [DirectoryItem] = [
        DirectoryItem(
            id: UUID(),
            name: "Photon",
            category: .particle,
            symbol: "γ",
            subtitle: "Quantum of Electromagnetic Radiation",
            properties: [
                "Mass": "0 eV/c²",
                "Spin": "1 (Boson)",
                "Charge": "0",
                "Velocity": "c (Speed of Light)"
            ],
            explanation: "A photon is an elementary particle representing the quantum of light and all other electromagnetic radiation. It acts as the force carrier for the electromagnetic force.",
            application: "Photons are fundamental to laser technology, optical communications, solar power generation, and quantum entanglement experiments.",
            concept: .waveParticle
        ),
        DirectoryItem(
            id: UUID(),
            name: "Electron",
            category: .particle,
            symbol: "e⁻",
            subtitle: "Fundamental Lepton",
            properties: [
                "Mass": "0.511 MeV/c²",
                "Spin": "1/2 (Fermion)",
                "Charge": "-1 e",
                "Mean Lifetime": "Stable (> 6.6 × 10²⁸ years)"
            ],
            explanation: "The electron is a subatomic particle whose electric charge is negative. It is an elementary particle belonging to the first generation of leptons, and plays a crucial role in electricity, magnetism, and chemical bonding.",
            application: "Electrons drive all modern electronic computers, electron microscopes, chemical sensors, and quantum computing qubits.",
            concept: .superposition
        ),
        DirectoryItem(
            id: UUID(),
            name: "Schrödinger Equation",
            category: .equation,
            symbol: "iℏ ∂/∂t Ψ = ĤΨ",
            subtitle: "Wave Mechanics Governing Equation",
            properties: [
                "Formulated": "Erwin Schrödinger (1925)",
                "Operator": "Ĥ (Hamiltonian)",
                "Output": "Ψ (Wavefunction)",
                "Variable": "t (Time)"
            ],
            explanation: "The Schrödinger equation is a linear partial differential equation that governs the wave function of a quantum-mechanical system, describing how its state changes over time.",
            application: "Used to calculate atomic structures, predict chemical properties, and model solid-state semiconductor devices.",
            concept: .superposition
        ),
        DirectoryItem(
            id: UUID(),
            name: "de Broglie Wavelength",
            category: .equation,
            symbol: "λ = h / p",
            subtitle: "Matter-Wave Duality Relation",
            properties: [
                "Formulated": "Louis de Broglie (1924)",
                "Variable": "λ (Wavelength)",
                "Constant": "h (Planck Constant)",
                "Momentum": "p (Particle Momentum)"
            ],
            explanation: "The de Broglie relation states that every moving particle has a wave associated with it. The wavelength of this matter wave is inversely proportional to the particle's momentum.",
            application: "Essential for electron diffraction, neutron scattering, and understanding modern electron holography.",
            concept: .waveParticle
        ),
        DirectoryItem(
            id: UUID(),
            name: "Bell's Inequality",
            category: .equation,
            symbol: "|E(a,b) - E(a,c)| ≤ 1 + E(b,c)",
            subtitle: "Local Realism Test Boundary",
            properties: [
                "Formulated": "John Stewart Bell (1964)",
                "Max Classical": "2 (CHSH Bound)",
                "Max Quantum": "2√2 (Tsirelson Bound)",
                "Core Concept": "Non-local Correlations"
            ],
            explanation: "Bell's Inequality provides a mathematical test to differentiate between classical local realism and quantum mechanics. Experiments repeatedly show quantum mechanics violates the inequality.",
            application: "Formulates the foundation of quantum key distribution (QKD) and quantum cryptography protocols.",
            concept: .entanglement
        ),
        DirectoryItem(
            id: UUID(),
            name: "Tesseract Geometry",
            category: .equation,
            symbol: "V = 16, E = 32, F = 24, C = 8",
            subtitle: "4-Dimensional Hypercube Equation",
            properties: [
                "Dimension": "4D Euclidean Space",
                "Vertices": "16",
                "Edges": "32",
                "Cubic Cells": "8"
            ],
            explanation: "A tesseract is the four-dimensional analogue of a cube. Rotating a tesseract in 4D space creates shadows in 3D that look like nested cubes shifting through each other.",
            application: "Useful in spatial modeling, studying higher-dimensional string theory configurations, and zero-point energy visualizations.",
            concept: .tesseract
        )
    ]
}

