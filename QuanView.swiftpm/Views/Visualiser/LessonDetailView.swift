import SwiftUI

struct LessonDetailView: View {
    let concept: QuantumConcept
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var progressManager: UserProgressManager
    
    @State private var executeSimulation = false
    @State private var resetSimulation = false
    @State private var capturePhoto = false
    @State private var isModelPlaced = false
    @State private var physicsIntensity: Float = 1.0
    @State private var capturedImage: UIImage?
    @State private var showInfo = true
    @State private var showCaptureConfirmation = false
    
    var body: some View {
        ZStack {
            ARViewContainer(
                concept: concept,
                executeSimulation: $executeSimulation,
                resetSimulation: $resetSimulation,
                capturePhoto: $capturePhoto,
                isModelPlaced: $isModelPlaced,
                physicsIntensity: $physicsIntensity,
                capturedImage: $capturedImage
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                if !isModelPlaced {
                    placementHint
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                controlsPanel
            }
            
            if showCaptureConfirmation {
                VStack {
                    Spacer()
                    Label("Log captured", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.bottom, 200)
                        .transition(.opacity)
                }
            }
        }
        .navigationTitle(concept.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { showInfo.toggle() }
                }) {
                    Image(systemName: showInfo ? "info.circle.fill" : "info.circle")
                        .foregroundStyle(.white)
                }
            }
        }
        .onChange(of: capturedImage) { newImage in
            if let img = newImage {
                progressManager.addRecord(image: img, for: concept)
                withAnimation(.easeInOut(duration: 0.2)) {
                    showCaptureConfirmation = true
                }
                Task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showCaptureConfirmation = false
                        }
                    }
                }
            }
        }
    }
    
    var placementHint: some View {
        Label("Tap a surface to place", systemImage: "viewfinder")
            .font(.callout.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
    }
    
    var controlsPanel: some View {
        VStack(spacing: 16) {
            if showInfo {
                VStack(alignment: .leading, spacing: 8) {
                    Text(concept.tagline.uppercased())
                        .font(.caption.bold())
                        .foregroundStyle(concept.themeColor)
                    Text(concept.description)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            VStack(spacing: 8) {
                HStack {
                    Label("Intensity", systemImage: "dial.medium.fill")
                        .font(.subheadline.bold())
                    Spacer()
                    Text("\(Int(physicsIntensity * 100))%")
                        .font(.subheadline.bold())
                        .foregroundStyle(concept.themeColor)
                }
                
                Slider(
                    value: Binding(
                        get: { Double(physicsIntensity) },
                        set: { physicsIntensity = Float($0) }
                    ),
                    in: 0.35...2.0
                )
                .tint(concept.themeColor)
            }
            
            VStack(spacing: 10) {
                Button(action: {
                    executeSimulation.toggle()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Label("Execute", systemImage: "play.fill")
                        .font(.system(.headline, design: .default))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .foregroundStyle(.white)
                        .background(isModelPlaced ? concept.themeColor : Color(.systemGray4))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!isModelPlaced)
                
                HStack(spacing: 12) {
                    Button(action: {
                        resetSimulation = true
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(.white)
                            .background(Color(.systemGray4))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!isModelPlaced)
                    .opacity(isModelPlaced ? 1 : 0.5)
                    
                    Button(action: {
                        capturePhoto = true
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }) {
                        Image(systemName: "camera.viewfinder")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(.black)
                            .background(.cyan)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!isModelPlaced)
                    .opacity(isModelPlaced ? 1 : 0.5)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .padding(.bottom, 60)
    }
}
