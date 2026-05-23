import Foundation
import SwiftUI
import UIKit

enum QuantumConcept: String, CaseIterable, Identifiable, Codable {
    case superposition, waveParticle, entanglement, tunneling, observer, tesseract
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .superposition: return "Superposition"
        case .waveParticle: return "Wave-Particle Duality"
        case .entanglement: return "Quantum Entanglement"
        case .tunneling: return "Quantum Tunneling"
        case .observer: return "The Observer Effect"
        case .tesseract: return "Zero-Point Tesseract"
        }
    }
    
    var tagline: String {
        switch self {
        case .superposition: return "Multi-state existence."
        case .waveParticle: return "Duality of matter."
        case .entanglement: return "Instantaneous correlation."
        case .tunneling: return "Bypassing barriers."
        case .observer: return "Measurement collapses reality."
        case .tesseract: return "Higher-dimensional anomalies."
        }
    }
    
    var themeColor: Color {
        switch self {
        case .superposition: return .cyan
        case .waveParticle: return .teal
        case .entanglement: return .white
        case .tunneling: return .orange
        case .observer: return .blue
        case .tesseract: return Color(red: 0.7, green: 1.0, blue: 0.9)
        }
    }
    
    var uiColor: UIColor {
        switch self {
        case .superposition: return .systemCyan
        case .waveParticle: return .systemTeal
        case .entanglement: return .white
        case .tunneling: return .systemOrange
        case .observer: return .systemBlue
        case .tesseract: return UIColor(red: 0.7, green: 1.0, blue: 0.9, alpha: 1.0)
        }
    }
    
    var description: String {
        switch self {
        case .superposition: return "A particle exists as a probability cloud of all possible states at once. It remains in flux until an interaction occurs."
        case .waveParticle: return "Quantum entities exhibit properties of both waves and particles depending on the method of measurement."
        case .entanglement: return "Particles become linked such that the state of one instantaneously influences the other, regardless of distance."
        case .tunneling: return "A phenomenon where particles pass through energy barriers that should be impassable according to classical physics."
        case .observer: return "The act of measurement collapses the quantum wavefunction, forcing a particle to choose a single definite state."
        case .tesseract: return "A four-dimensional geometric anomaly representing zero-point energy fluctuations in a stabilized vacuum."
        }
    }
    
    var modelAssetName: String {
        switch self {
        case .superposition: return "Atomic_Orbitals"
        case .waveParticle: return "YOUNGS_DOUBLE_SLIT_EXPERIMENT"
        case .entanglement: return "atom_3D"
        case .tunneling: return "Atomic_Models"
        case .observer: return "Atomic_Models"
        case .tesseract: return "Tesseract"
        }
    }
    
    var viewerFitSize: Float {
        switch self {
        case .superposition: return 0.72
        case .waveParticle: return 0.82
        case .entanglement: return 0.68
        case .tunneling: return 0.78
        case .observer: return 0.78
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
        case .tunneling:
            return "Use the atomic model gallery as the context, then run the particle through the barrier."
        case .observer:
            return "Compare the model before and after measurement to see how observation changes the displayed state."
        case .tesseract:
            return "Inspect the higher-dimensional frame, then execute the zero-point expansion."
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
        return """
        QUANTUM SIGNATURE: VERIFIED
        COHERENCE: \(Int.random(in: 92...99))%
        FIELD STABILITY: NOMINAL
        
        Observation confirms \(concept.title) characteristics. Particle distribution matches theoretical models with zero detectable decoherence.
        """
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
