import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var progressManager: UserProgressManager
    @Environment(\.dismiss) private var dismiss
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: Profile Header
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan.opacity(0.8), .blue.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "atom")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Quantum Researcher")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                            
                            Text("\(progressManager.completedConcepts.count) of \(QuantumConcept.allCases.count) modules mastered")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // MARK: Overview & Progress
                Section("Overview") {
                    LabeledContent {
                        Text("\(progressManager.completedConcepts.count) / \(QuantumConcept.allCases.count)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    } label: {
                        Label {
                            Text("Modules Mastered")
                        } icon: {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.cyan)
                        }
                    }
                    
                    LabeledContent {
                        Text("\(progressManager.totalSimulationsRun)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    } label: {
                        Label {
                            Text("Simulations Executed")
                        } icon: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(.teal)
                        }
                    }

                    LabeledContent {
                        Text("\(progressManager.records.count)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    } label: {
                        Label {
                            Text("Lab Notebook Entries")
                        } icon: {
                            Image(systemName: "book.closed.fill")
                                .foregroundStyle(.indigo)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Curriculum Progress")
                                .font(.subheadline)
                            Spacer()
                            Text("\(Int(progressManager.completionRatio * 100))%")
                                .font(.subheadline.bold())
                                .foregroundStyle(.cyan)
                                .monospacedDigit()
                        }
                        
                        ProgressView(value: progressManager.completionRatio)
                            .tint(.cyan)
                    }
                    .padding(.vertical, 4)
                }

                // MARK: Curriculum Checklist
                Section("Curriculum Checklist") {
                    ForEach(QuantumConcept.allCases) { concept in
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(concept.themeColor.opacity(0.15))
                                    .frame(width: 28, height: 28)
                                
                                Image(systemName: progressManager.completedConcepts.contains(concept) ? "checkmark" : "clock")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(progressManager.completedConcepts.contains(concept) ? concept.themeColor : .gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(concept.title)
                                    .font(.body)
                                Text(concept.tagline)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if progressManager.completedConcepts.contains(concept) {
                                Text("COMPLETED")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundStyle(concept.themeColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(concept.themeColor.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                // MARK: About & App Settings
                Section("About") {
                    NavigationLink {
                        PrivacyInfoView()
                    } label: {
                        Label {
                            Text("Privacy & Data Protection")
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(.blue)
                        }
                    }

                    LabeledContent {
                        Text("2.0.4")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    } label: {
                        Label {
                            Text("App Version")
                        } icon: {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                }

                // MARK: Danger Zone
                Section {
                    Button(role: .destructive) {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        showResetAlert = true
                    } label: {
                        Label {
                            Text("Reset All Data & Progress")
                                .foregroundStyle(.red)
                        } icon: {
                            Image(systemName: "trash.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.body.bold())
                }
            }
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    progressManager.resetAllData()
                }
            } message: {
                Text("This will permanently delete all lab notebook entries and reset your progress. This action cannot be undone.")
            }
        }
    }
}

// MARK: - Privacy Info

struct PrivacyInfoView: View {
    var body: some View {
        List {
            Section("Data Privacy") {
                Label("No account or sign-in required", systemImage: "person.crop.circle.badge.checkmark")
                Label("All lab logs stay encrypted on your device", systemImage: "lock.shield.fill")
                Label("Camera is accessed solely for real-world AR placement", systemImage: "camera.fill")
            }
            
            Section("Security Note") {
                Text("QuanView respects user privacy. No telemetry, analytical data, or camera feeds are transmitted off your device.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Privacy & Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserProgressManager())
}
