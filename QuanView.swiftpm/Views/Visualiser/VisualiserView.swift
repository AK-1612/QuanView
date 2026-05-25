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
    @State private var showInfo = false

    init(initialConcept: QuantumConcept) {
        self.concept = initialConcept
    }

    var body: some View {
        VStack(spacing: 0) {
            // Segmented control bar, directly below the nav bar
            Picker("Mode", selection: $mode) {
                ForEach(VisualiserMode.allCases) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(white: 0.08))

            // Viewer fills all remaining space
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)

                if mode == .room {
                    roomControls
                }
            }
        }
        .background(Color(white: 0.045))
        .navigationTitle(concept.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Redo — resets the experiment back to its initial state
                Button {
                    resetView = true
                    // Also reset the interaction so the scene rebuilds cleanly
                    interactionCommand = 0
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .accessibilityLabel("Reset experiment")

                // Info — Foundation Model description sheet
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel("Experiment info")
            }
        }
        .sheet(isPresented: $showInfo) {
            ExperimentInfoSheet(concept: concept)
        }
    }

    // MARK: - Room controls — single HStack: Execute · Pause · Redo

    var roomControls: some View {
        HStack(spacing: 10) {
            // Execute — primary, takes most space
            Button {
                interactionCommand += 1
                isAnimating = true
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Label("Execute", systemImage: "bolt.fill")
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(.black)
                    .background(concept.themeColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Pause / Play
            Button {
                isAnimating.toggle()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: isAnimating ? "pause.fill" : "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.white)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .accessibilityLabel(isAnimating ? "Pause" : "Play")

            // Redo — rebuilds the scene from scratch
            Button {
                resetView = true
                interactionCommand = 0
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.white)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .accessibilityLabel("Reset experiment")
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 14)
        .padding(.bottom, 24)
    }
}

// MARK: - Experiment info sheet

struct ExperimentInfoSheet: View {
    let concept: QuantumConcept
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Icon + title
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(concept.themeColor.opacity(0.15))
                                .frame(width: 56, height: 56)
                            Image(systemName: "atom")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(concept.themeColor)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Exp. \(concept.experimentNumber)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(concept.themeColor)
                            Text(concept.title)
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                        }
                    }

                    // Tagline
                    Text(concept.tagline.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(concept.themeColor.opacity(0.8))
                        .tracking(1)

                    Divider()
                        .background(Color.white.opacity(0.1))

                    // Description
                    infoSection(label: "ABOUT THIS EXPERIMENT") {
                        Text(concept.description)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.85))
                            .lineSpacing(5)
                    }

                    // Prompt
                    infoSection(label: "WHAT TO OBSERVE") {
                        Text(concept.experimentPrompt)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.85))
                            .lineSpacing(5)
                    }

                    // Foundation Model context
                    infoSection(label: "PHYSICS BACKGROUND") {
                        Text(concept.physicsBackground)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.85))
                            .lineSpacing(5)
                    }
                }
                .padding(20)
                .padding(.bottom, 32)
            }
            .background(Color(white: 0.06).ignoresSafeArea())
            .navigationTitle("Experiment Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    func infoSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(concept.themeColor)
                .tracking(1.5)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(concept.themeColor.opacity(0.15), lineWidth: 1))
    }
}
