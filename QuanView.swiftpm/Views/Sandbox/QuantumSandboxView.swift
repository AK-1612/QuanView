import SwiftUI
import ARKit

struct QuantumSandboxView: View {
    let concept: QuantumConcept
    @EnvironmentObject var progressManager: UserProgressManager
    @StateObject private var viewModel: SandboxViewModel
    @State private var showCaptureConfirmation = false
    
    init(concept: QuantumConcept) {
        self.concept = concept
        self._viewModel = StateObject(wrappedValue: SandboxViewModel(concept: concept))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Room/AR Toggle
            Picker("Mode", selection: $viewModel.mode) {
                Text("Room").tag("Room")
                Text("AR").tag("AR")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(white: 0.08))
            
            // 3D Scene View Area
            ZStack(alignment: .bottom) {
                if viewModel.mode == "Room" {
                    ModelViewerContainer(
                        concept: concept,
                        isAnimating: $viewModel.isAnimating,
                        resetView: $viewModel.resetView,
                        zoomCommand: $viewModel.zoomCommand,
                        interactionCommand: $viewModel.interactionCommand,
                        slideIndex: -1 // Sandbox mode uses raw interactive commands
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .bottom)
                } else {
                    if ARWorldTrackingConfiguration.isSupported {
                        arSandboxBody
                    } else {
                        arUnavailableBody
                    }
                }
                
                if showCaptureConfirmation {
                    Label("Log captured & stored", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 120)
                        .transition(.opacity)
                }
            }
            .background(Color(white: 0.02))
            
            // Sliders and Run Controls Panel
            VStack(spacing: 16) {
                // Parameter tuning card
                parameterControlsCard
                
                // Primary action buttons
                HStack(spacing: 12) {
                    // Execute
                    Button(action: {
                        if viewModel.mode == "Room" {
                            viewModel.interactionCommand += 1
                        } else {
                            viewModel.executeSimulation.toggle()
                        }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        Label("Execute Action", systemImage: "bolt.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .foregroundStyle(.black)
                            .background(concept.themeColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Reset
                    Button(action: {
                        viewModel.resetSandbox()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.headline)
                            .frame(width: 52, height: 52)
                            .foregroundStyle(.white)
                            .background(Color.white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(16)
            .background(Color(white: 0.06))
        }
        .navigationTitle(concept.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(white: 0.035).ignoresSafeArea())
        .onChange(of: viewModel.capturedImage) { newImage in
            if let img = newImage {
                progressManager.addRecord(image: img, for: concept)
                withAnimation(.easeInOut(duration: 0.2)) {
                    showCaptureConfirmation = true
                }
                Task {
                    try? await Task.sleep(nanoseconds: 1_600_000_000)
                    await MainActor.run {
                        withAnimation {
                            showCaptureConfirmation = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - AR Specific UI
    
    var arSandboxBody: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(
                concept: concept,
                executeSimulation: $viewModel.executeSimulation,
                resetSimulation: $viewModel.resetSimulation,
                capturePhoto: $viewModel.capturePhoto,
                isModelPlaced: $viewModel.isModelPlaced,
                physicsIntensity: $viewModel.physicsIntensity,
                capturedImage: $viewModel.capturedImage
            )
            .ignoresSafeArea()
            
            if !viewModel.isModelPlaced {
                Label("Tap a flat surface to place in AR", systemImage: "viewfinder")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 32)
            } else {
                // Floating Camera Trigger
                Button(action: {
                    viewModel.capturePhoto = true
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.black)
                        .background(.cyan)
                        .clipShape(Circle())
                        .shadow(color: .cyan.opacity(0.4), radius: 8)
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    var arUnavailableBody: some View {
        VStack(spacing: 12) {
            Image(systemName: "arkit")
                .font(.system(size: 40))
                .foregroundStyle(.gray)
            Text("AR Mode Unsupported")
                .font(.headline)
                .foregroundStyle(.white)
            Text("ARKit is not supported on this device. Please use Room Mode.")
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Parameter Tuning Card
    
    var parameterControlsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("PHYSICAL CONSTANTS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(concept.themeColor)
                
                Spacer()
                
                Label("Physics Rate", systemImage: "dial.medium.fill")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.gray)
            }
            
            // Core physical variables based on concept
            switch concept {
            case .superposition:
                VStack(spacing: 8) {
                    HStack {
                        Text("Orbital Shell (n)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("n = \(viewModel.orbitalN)")
                            .font(.system(.subheadline, design: .monospaced).bold())
                            .foregroundStyle(concept.themeColor)
                    }
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.orbitalN) },
                            set: { viewModel.orbitalN = Int($0) }
                        ),
                        in: 1...4,
                        step: 1
                    )
                    .tint(concept.themeColor)
                }
            case .waveParticle:
                VStack(spacing: 8) {
                    HStack {
                        Text("Slit Separation (d)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(String(format: "%.3f nm", viewModel.slitDistance * 1000))
                            .font(.system(.subheadline, design: .monospaced).bold())
                            .foregroundStyle(concept.themeColor)
                    }
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.slitDistance) },
                            set: { viewModel.slitDistance = Float($0) }
                        ),
                        in: 0.02...0.12
                    )
                    .tint(concept.themeColor)
                }
            case .entanglement:
                VStack(spacing: 8) {
                    HStack {
                        Text("Detector A Filter Angle")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(String(format: "%.1f°", viewModel.polarizationAngle))
                            .font(.system(.subheadline, design: .monospaced).bold())
                            .foregroundStyle(concept.themeColor)
                    }
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.polarizationAngle) },
                            set: { viewModel.polarizationAngle = Float($0) }
                        ),
                        in: 0...90,
                        step: 22.5
                    )
                    .tint(concept.themeColor)
                }
            case .tesseract:
                VStack(spacing: 8) {
                    HStack {
                        Text("W-Axis Rotation Speed")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(String(format: "%.2fx", viewModel.rotationSpeed4D))
                            .font(.system(.subheadline, design: .monospaced).bold())
                            .foregroundStyle(concept.themeColor)
                    }
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.rotationSpeed4D) },
                            set: { viewModel.rotationSpeed4D = Float($0) }
                        ),
                        in: 0.2...2.5
                    )
                    .tint(concept.themeColor)
                }
            }
        }
        .padding(14)
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(concept.themeColor.opacity(0.15), lineWidth: 1)
        )
    }
}
