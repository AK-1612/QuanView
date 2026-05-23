import SwiftUI
import ARKit

struct RealWorldVisualiserView: View {
    let concept: QuantumConcept
    @EnvironmentObject var progressManager: UserProgressManager
    
    @State private var executeSimulation = false
    @State private var resetSimulation = false
    @State private var capturePhoto = false
    @State private var isModelPlaced = false
    @State private var physicsIntensity: Float = 1.0
    @State private var capturedImage: UIImage?
    @State private var showCaptureConfirmation = false
    
    var body: some View {
        Group {
            if ARWorldTrackingConfiguration.isSupported {
                arExperience
            } else {
                unavailableState
            }
        }
    }
    
    var arExperience: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(
                concept: concept,
                executeSimulation: $executeSimulation,
                resetSimulation: $resetSimulation,
                capturePhoto: $capturePhoto,
                isModelPlaced: $isModelPlaced,
                physicsIntensity: $physicsIntensity,
                capturedImage: $capturedImage
            )
            .ignoresSafeArea(edges: .bottom)
            
            if !isModelPlaced {
                VStack {
                    Label("Move slowly, then tap a detected surface", systemImage: "viewfinder")
                        .font(.system(.footnote, design: .monospaced))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer()
                }
                .padding(.top, 16)
            }
            
            controls
            
            if showCaptureConfirmation {
                Label("Log captured", systemImage: "checkmark.circle.fill")
                    .font(.system(.subheadline, design: .monospaced).bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 168)
                    .transition(.opacity)
            }
        }
        .onChange(of: capturedImage) { newImage in
            guard let image = newImage else { return }
            progressManager.addRecord(image: image, for: concept)
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
    
    var unavailableState: some View {
        VStack(spacing: 16) {
            Image(systemName: "arkit")
                .font(.system(size: 54, weight: .light))
                .foregroundStyle(concept.themeColor)
            Text("Real-world viewing needs a device with ARKit.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            Text("Use Room mode in Simulator. On iPhone or iPad, this mode opens the camera and places the same model into your space.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.045))
    }
    
    var controls: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Intensity", systemImage: "dial.medium")
                Spacer()
                Text("\(Int(physicsIntensity * 100))%")
            }
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.white.opacity(0.72))
            
            Slider(
                value: Binding(
                    get: { Double(physicsIntensity) },
                    set: { physicsIntensity = Float($0) }
                ),
                in: 0.35...2.0
            )
            .tint(concept.themeColor)
            
            HStack(spacing: 10) {
                Button {
                    executeSimulation.toggle()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Label("Run", systemImage: "play.fill")
                        .font(.system(.headline, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isModelPlaced ? concept.themeColor : Color.white.opacity(0.16))
                        .foregroundStyle(isModelPlaced ? .black : .white.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(!isModelPlaced)
                
                Button {
                    resetSimulation = true
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline.bold())
                        .frame(width: 50, height: 50)
                        .background(.white.opacity(0.12))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(!isModelPlaced)
                .opacity(isModelPlaced ? 1 : 0.45)
                
                Button {
                    capturePhoto = true
                } label: {
                    Image(systemName: "camera.viewfinder")
                        .font(.headline.bold())
                        .frame(width: 50, height: 50)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(!isModelPlaced)
                .opacity(isModelPlaced ? 1 : 0.45)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
    }
}
