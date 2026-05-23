import SwiftUI

enum VisualiserMode: String, CaseIterable, Identifiable {
    case room = "Room"
    case realWorld = "Real World"
    
    var id: String { rawValue }
}

struct VisualiserView: View {
    let concept: QuantumConcept
    @State private var mode: VisualiserMode = .room
    @State private var isAnimating = true
    @State private var resetView = false
    @State private var zoomCommand = 0
    @State private var interactionCommand = 0
    
    init(initialConcept: QuantumConcept) {
        self.concept = initialConcept
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.045).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Picker("Viewing mode", selection: $mode) {
                        ForEach(VisualiserMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding([.horizontal, .top])
                    .accessibilityLabel("Viewing mode")
                    .padding(.bottom, 10)
                    
                    ZStack(alignment: .bottom) {
                        Group {
                            if mode == .room {
                                ModelViewerContainer(
                                    concept: concept,
                                    isAnimating: $isAnimating,
                                    resetView: $resetView,
                                    zoomCommand: $zoomCommand,
                                    interactionCommand: $interactionCommand
                                )
                            } else {
                                RealWorldVisualiserView(concept: concept)
                            }
                        }
                        .ignoresSafeArea(edges: .bottom)
                        
                        if mode == .room {
                            roomControls
                        }
                    }
                }
            }
            .navigationTitle(concept.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileToolbarButton()
                }
            }
        }
    }
    
    var roomControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(concept.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text(concept.experimentPrompt)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            HStack(spacing: 10) {
                Button {
                    interactionCommand += 1
                    isAnimating = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Label("Execute", systemImage: "bolt.fill")
                        .font(.system(.subheadline, design: .monospaced).bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(concept.themeColor)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Button {
                    isAnimating.toggle()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: isAnimating ? "pause.fill" : "play.fill")
                        .font(.headline.bold())
                        .frame(width: 46)
                        .frame(height: 44)
                        .background(.white.opacity(0.12))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .accessibilityLabel(isAnimating ? "Pause ambient motion" : "Play ambient motion")
                
                Button {
                    zoomCommand -= 1
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.headline.bold())
                        .frame(width: 46, height: 44)
                        .background(.white.opacity(0.12))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .accessibilityLabel("Zoom out")
                
                Button {
                    zoomCommand += 1
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.headline.bold())
                        .frame(width: 46, height: 44)
                        .background(.white.opacity(0.12))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .accessibilityLabel("Zoom in")
                
                Button {
                    resetView = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.headline.bold())
                        .frame(width: 46, height: 44)
                        .background(.white.opacity(0.12))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .accessibilityLabel("Reset view")
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}
