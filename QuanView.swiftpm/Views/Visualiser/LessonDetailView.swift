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
                topBar
                
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
                        .font(.system(.subheadline, design: .monospaced).bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.bottom, 168)
                        .transition(.opacity)
                }
            }
        }
        .navigationBarHidden(true)
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
    
    var topBar: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.headline.bold())
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(concept.title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(isModelPlaced ? "FIELD LOCKED" : "SEEKING SURFACE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(isModelPlaced ? concept.themeColor : .white.opacity(0.55))
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) { showInfo.toggle() }
            }) {
                Image(systemName: showInfo ? "info.circle.fill" : "info.circle")
                    .font(.headline)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .foregroundStyle(.white)
        .padding()
    }
    
    var placementHint: some View {
        Label("Tap a detected surface to place the module", systemImage: "viewfinder")
            .font(.system(.footnote, design: .monospaced))
            .foregroundStyle(.white.opacity(0.82))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.46))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
    }
    
    var controlsPanel: some View {
        VStack(spacing: 16) {
            if showInfo {
                VStack(alignment: .leading, spacing: 8) {
                    Text(concept.tagline.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(concept.themeColor)
                    Text(concept.description)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.black.opacity(0.32))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            VStack(spacing: 6) {
                HStack {
                    Label("Intensity", systemImage: "dial.medium")
                    Spacer()
                    Text("\(Int(physicsIntensity * 100))%")
                }
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.white.opacity(0.68))
                
                Slider(
                    value: Binding(
                        get: { Double(physicsIntensity) },
                        set: { physicsIntensity = Float($0) }
                    ),
                    in: 0.35...2.0
                )
                .tint(concept.themeColor)
            }
            
            HStack(spacing: 10) {
                Button(action: {
                    executeSimulation.toggle()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }) {
                    Label("EXECUTE", systemImage: "play.fill")
                        .font(.system(.headline, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(isModelPlaced ? concept.themeColor : Color.white.opacity(0.16))
                        .foregroundStyle(isModelPlaced ? .black : .white.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(!isModelPlaced)
                
                Button(action: {
                    resetSimulation = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3.bold())
                        .frame(width: 54, height: 54)
                        .background(.white.opacity(0.12))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(!isModelPlaced)
                .opacity(isModelPlaced ? 1 : 0.45)
                
                Button(action: {
                    capturePhoto = true
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }) {
                    Image(systemName: "camera.viewfinder")
                        .font(.title3.bold())
                        .frame(width: 54, height: 54)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(!isModelPlaced)
                .opacity(isModelPlaced ? 1 : 0.45)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
    }
}
