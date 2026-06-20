import SwiftUI

struct SandboxListView: View {
    @EnvironmentObject var progressManager: UserProgressManager
    @State private var showingNotebook = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.035).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("QUANTUM SANDBOXES")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(.cyan)
                                .tracking(2)
                            
                            Text("Interactive Labs")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("Adjust physical constants, spin higher dimensions, collapse states, and capture logs in AR.")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .lineSpacing(3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Sandbox list
                        VStack(spacing: 16) {
                            ForEach(QuantumConcept.allCases) { concept in
                                NavigationLink(destination: QuantumSandboxView(concept: concept)) {
                                    SandboxListCard(concept: concept)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Sandbox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Lab Notebook
                    Button(action: {
                        showingNotebook = true
                    }) {
                        Label("Lab Logs", systemImage: "doc.viewfinder")
                            .foregroundStyle(.cyan)
                    }
                    
                    ProfileToolbarButton()
                }
            }
            .sheet(isPresented: $showingNotebook) {
                NavigationStack {
                    LabNotebookView()
                        .environmentObject(progressManager)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") {
                                    showingNotebook = false
                                }
                            }
                        }
                }
            }
        }
    }
}

struct SandboxListCard: View {
    let concept: QuantumConcept
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(concept.themeColor.opacity(0.12))
                    .frame(width: 56, height: 56)
                
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 22))
                    .foregroundStyle(concept.themeColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("LAB \(concept.experimentNumber)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(concept.themeColor)
                
                Text(concept.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text("Tap to configure sliders and run")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.25))
        }
        .padding(16)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(concept.themeColor.opacity(0.15), lineWidth: 1)
        )
    }
}
