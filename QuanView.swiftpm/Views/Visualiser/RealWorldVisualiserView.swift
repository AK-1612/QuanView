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
    @State private var showIntensity = false

    var body: some View {
        Group {
            if ARWorldTrackingConfiguration.isSupported {
                arExperience
            } else {
                unavailableState
            }
        }
    }

    // MARK: - AR experience (full screen)

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
            .ignoresSafeArea()

            // Placement hint
            if !isModelPlaced {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "viewfinder")
                        Text("Move slowly · tap a surface to place")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 120)
                    Spacer()
                }
                .transition(.opacity)
            }

            // Capture confirmation toast
            if showCaptureConfirmation {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Log captured")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 11)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, 160)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }

            controls
        }
        .onChange(of: capturedImage) { newImage in
            guard let image = newImage else { return }
            progressManager.addRecord(image: image, for: concept)
            withAnimation(.spring(response: 0.3)) { showCaptureConfirmation = true }
            Task {
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                await MainActor.run {
                    withAnimation { showCaptureConfirmation = false }
                }
            }
        }
    }

    // MARK: - Controls panel

    var controls: some View {
        VStack(spacing: 10) {
            // Collapsible intensity slider
            if showIntensity {
                VStack(spacing: 6) {
                    HStack {
                        Label("Intensity", systemImage: "dial.medium")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.75))
                        Spacer()
                        Text("\(Int(physicsIntensity * 100))%")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.75))
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
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            HStack(spacing: 8) {
                // Run
                Button {
                    executeSimulation.toggle()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Label("Run", systemImage: "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isModelPlaced ? concept.themeColor : Color.white.opacity(0.14))
                        .foregroundStyle(isModelPlaced ? .black : .white.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(!isModelPlaced)

                // Reset
                Button {
                    resetSimulation = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 50, height: 50)
                        .background(.white.opacity(0.12))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(!isModelPlaced)
                .opacity(isModelPlaced ? 1 : 0.4)

                // Intensity toggle
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showIntensity.toggle() }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "dial.medium")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 50, height: 50)
                        .background(showIntensity ? concept.themeColor.opacity(0.3) : .white.opacity(0.12))
                        .foregroundStyle(showIntensity ? concept.themeColor : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Capture
                Button {
                    capturePhoto = true
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                } label: {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 50, height: 50)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(!isModelPlaced)
                .opacity(isModelPlaced ? 1 : 0.4)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 14)
        .padding(.bottom, 28)
    }

    // MARK: - Unavailable state

    var unavailableState: some View {
        VStack(spacing: 18) {
            Image(systemName: "arkit")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(concept.themeColor)
            Text("ARKit not available")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text("Real World mode requires a device with ARKit support. Use Room mode in Simulator.")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.045))
    }
}
