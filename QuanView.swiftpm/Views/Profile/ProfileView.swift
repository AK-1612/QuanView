import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var progressManager: UserProgressManager
    @Environment(\.dismiss) private var dismiss
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.045).ignoresSafeArea()
                
                List {
                    Section {
                        HStack(spacing: 16) {
                            ProgressBadge(progress: progressManager.completionRatio)
                                .frame(width: 86, height: 86)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Lead Researcher")
                                    .font(.system(.title3, design: .monospaced))
                                    .bold()
                                    .foregroundStyle(.white)
                                
                                Text("QuanView Profile")
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundStyle(.gray)
                                
                                Text("Clearance: Level 5")
                                    .font(.system(size: 10, design: .monospaced))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.cyan.opacity(0.2))
                                    .foregroundStyle(.cyan)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 10)
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                    
                    Section(header: Text("Progress").font(.system(.caption, design: .monospaced))) {
                        StatRow(title: "Simulations Run", value: "\(progressManager.totalSimulationsRun)", icon: "atom", color: .cyan)
                        StatRow(title: "Photographic Logs", value: "\(progressManager.records.count)", icon: "camera.viewfinder", color: .teal)
                        StatRow(title: "Modules Completed", value: "\(progressManager.completedConcepts.count) / \(QuantumConcept.allCases.count)", icon: "checkmark.seal", color: .white)
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section(header: Text("Completed Modules").font(.system(.caption, design: .monospaced))) {
                        ForEach(QuantumConcept.allCases) { concept in
                            HStack {
                                Image(systemName: progressManager.completedConcepts.contains(concept) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(progressManager.completedConcepts.contains(concept) ? concept.themeColor : .gray)
                                    .frame(width: 24)
                                Text(concept.title)
                                    .font(.system(.body, design: .monospaced))
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section(header: Text("Data Management").font(.system(.caption, design: .monospaced))) {
                        Button(role: .destructive) {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            showResetAlert = true
                        } label: {
                            Label("Decommission Lab Data", systemImage: "exclamationmark.shield")
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section(header: Text("Privacy & Credits").font(.system(.caption, design: .monospaced))) {
                        NavigationLink {
                            AppStoreReadinessView()
                        } label: {
                            Label("App Store Readiness", systemImage: "checkmark.shield")
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        NavigationLink {
                            ModelCreditsView()
                        } label: {
                            Label("Model Credits", systemImage: "cube.transparent")
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section {
                        HStack {
                            Text("Build Version")
                            Spacer()
                            Text("2.0.4-Stable")
                                .foregroundStyle(.gray)
                        }
                        .font(.system(.caption, design: .monospaced))
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Wipe Research Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Erase All", role: .destructive) {
                    progressManager.resetAllData()
                }
            } message: {
                Text("This action will permanently purge all photographic logs and reset your QuanView progress. This cannot be undone.")
            }
        }
    }
}

struct AppStoreReadinessView: View {
    var body: some View {
        List {
            Section("Privacy") {
                Label("No account or sign-in required", systemImage: "person.crop.circle.badge.checkmark")
                Label("Experiment logs stay on device", systemImage: "lock")
                Label("Camera is only used for Real World mode", systemImage: "camera.viewfinder")
            }
            
            Section("Review Notes") {
                Text("Room mode provides a complete simulator-friendly experience. Real World mode is gated behind ARKit support and shows an explanatory state on unsupported devices.")
                Text("Before App Store submission, add the public privacy policy URL in App Store Connect metadata.")
            }
        }
        .navigationTitle("Readiness")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ModelCreditsView: View {
    var body: some View {
        List {
            Section("Bundled Models") {
                CreditRow(title: "Atomic Orbitals", fileName: "Atomic_Orbitals.usdz")
                CreditRow(title: "Young's Double Slit Experiment", fileName: "YOUNGS_DOUBLE_SLIT_EXPERIMENT.usdz")
                CreditRow(title: "Atom 3D", fileName: "atom_3D.usdz")
                CreditRow(title: "Atomic Models", fileName: "Atomic_Models.usdz")
                CreditRow(title: "Tesseract", fileName: "Tesseract.usdz")
            }
            
            Section("Submission Note") {
                Text("Keep creator names, source links, and license terms here before App Store submission.")
            }
        }
        .navigationTitle("Credits")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CreditRow: View {
    let title: String
    let fileName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
            Text(fileName)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.gray)
        }
    }
}

struct ProgressBadge: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.cyan, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Image(systemName: "person.badge.shield.checkmark")
                    .font(.title3)
                    .foregroundStyle(.cyan)
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(title)
                .font(.system(.body, design: .monospaced))
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
                .bold()
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserProgressManager())
        .preferredColorScheme(.dark)
}
