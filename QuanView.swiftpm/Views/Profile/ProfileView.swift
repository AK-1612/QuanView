import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var progressManager: UserProgressManager
    @Environment(\.dismiss) private var dismiss
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: Avatar + name header
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 64, height: 64)
                            Image(systemName: "person.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color(.systemGray2))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Researcher")
                                .font(.title3.bold())
                            Text("QuanView · \(progressManager.completedConcepts.count) of \(QuantumConcept.allCases.count) experiments complete")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                // MARK: Progress
                Section("Progress") {
                    LabeledContent("Experiments Completed") {
                        Text("\(progressManager.completedConcepts.count) / \(QuantumConcept.allCases.count)")
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("Simulations Run") {
                        Text("\(progressManager.totalSimulationsRun)")
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("Log Entries") {
                        Text("\(progressManager.records.count)")
                            .foregroundStyle(.secondary)
                    }

                    // Progress bar row
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Overall")
                                .font(.subheadline)
                            Spacer()
                            Text("\(Int(progressManager.completionRatio * 100))%")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: progressManager.completionRatio)
                            .tint(.cyan)
                    }
                    .padding(.vertical, 4)
                }

                // MARK: Experiments
                Section("Experiments") {
                    ForEach(QuantumConcept.allCases) { concept in
                        HStack {
                            Image(systemName: progressManager.completedConcepts.contains(concept)
                                  ? "checkmark.circle.fill"
                                  : "circle")
                                .foregroundStyle(progressManager.completedConcepts.contains(concept)
                                                 ? .cyan : Color(.systemGray3))
                            Text(concept.title)
                        }
                    }
                }

                // MARK: About
                Section("About") {
                    NavigationLink {
                        ModelCreditsView()
                    } label: {
                        Label("Model Credits", systemImage: "cube.transparent")
                    }

                    NavigationLink {
                        PrivacyInfoView()
                    } label: {
                        Label("Privacy", systemImage: "hand.raised")
                    }

                    LabeledContent("Version") {
                        Text("2.0.4")
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: Data
                Section {
                    Button(role: .destructive) {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        showResetAlert = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    progressManager.resetAllData()
                }
            } message: {
                Text("This will permanently delete all log entries and reset your progress. This cannot be undone.")
            }
        }
    }
}

// MARK: - Model Credits

struct ModelCreditsView: View {
    var body: some View {
        List {
            Section("Bundled 3D Models") {
                CreditRow(title: "Atomic Orbitals", fileName: "Atomic_Orbitals.usdz")
                CreditRow(title: "Young's Double Slit", fileName: "YOUNGS_DOUBLE_SLIT_EXPERIMENT.usdz")
                CreditRow(title: "Atom 3D", fileName: "atom_3D.usdz")
                CreditRow(title: "Tesseract", fileName: "Tesseract.usdz")
            }
            Section {
                Text("Add creator names, source links, and license terms here before App Store submission.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Model Credits")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Privacy Info

struct PrivacyInfoView: View {
    var body: some View {
        List {
            Section("Data") {
                Label("No account or sign-in required", systemImage: "person.crop.circle.badge.checkmark")
                Label("All logs stay on your device", systemImage: "lock")
                Label("Camera used only in Real World mode", systemImage: "camera")
            }
            Section("Submission Note") {
                Text("Add your public privacy policy URL in App Store Connect before submission.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Shared subviews

struct CreditRow: View {
    let title: String
    let fileName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
            Text(fileName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserProgressManager())
}
