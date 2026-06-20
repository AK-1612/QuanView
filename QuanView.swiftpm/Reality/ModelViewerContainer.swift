import SwiftUI
import RealityKit
import UIKit
import Combine

@MainActor
struct ModelViewerContainer: UIViewRepresentable {
    let concept: QuantumConcept
    @Binding var isAnimating: Bool
    @Binding var resetView: Bool
    @Binding var zoomCommand: Int
    @Binding var interactionCommand: Int
    var slideIndex: Int = -1
    
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        view.environment.background = .color(UIColor(red: 0.025, green: 0.03, blue: 0.035, alpha: 1))
        // Disable post-process effects that cause the grey film overlay
        view.renderOptions = [.disableDepthOfField, .disableMotionBlur, .disableFaceOcclusions, .disablePersonOcclusion, .disableGroundingShadows]
        
        context.coordinator.view = view
        context.coordinator.installGestures(on: view)
        context.coordinator.buildScene(for: concept)
        return view
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if context.coordinator.currentConcept != concept {
            context.coordinator.buildScene(for: concept)
        }
        
        context.coordinator.isAnimating = isAnimating
        
        if resetView {
            context.coordinator.resetCamera()
            Task { @MainActor in resetView = false }
        }
        
        context.coordinator.applyZoomCommand(zoomCommand)
        context.coordinator.applyInteractionCommand(interactionCommand)
        context.coordinator.applySlideIndex(slideIndex)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    @MainActor
    final class Coordinator: NSObject {
        weak var view: ARView?
        var currentConcept: QuantumConcept?
        var anchor = AnchorEntity(world: .zero)
        var modelRoot = Entity()
        var cameraAnchor = AnchorEntity(world: .zero)
        var camera = PerspectiveCamera()
        var updateSubscription: Cancellable?
        var isAnimating = true
        var yaw: Float = 0
        var pitch: Float = -0.18
        var distance: Float = 1.65
        var defaultDistance: Float = 1.65
        var lastScale: CGFloat = 1
        var handledZoomCommand = 0
        var handledInteractionCommand = 0
        var currentSlideIndex = -1
        var isInteracting = false
        var interactionElapsed: Float = 0
        let interactionDuration: Float = 3.0
        var time: Float = 0
        
        func installGestures(on view: ARView) {
            view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
            view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinch)))
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        }
        
        func buildScene(for concept: QuantumConcept) {
            guard let view else { return }
            currentConcept = concept
            view.scene.anchors.removeAll()
            anchor = AnchorEntity(world: .zero)
            modelRoot = Entity()
            cameraAnchor = AnchorEntity(world: .zero)
            camera = PerspectiveCamera()
            
            addRoom(to: anchor, tint: concept.uiColor)
            loadModel(for: concept)
            addExperimentLayer(for: concept)
            anchor.addChild(modelRoot)
            view.scene.addAnchor(anchor)
            
            camera.camera.fieldOfViewInDegrees = 52
            cameraAnchor.addChild(camera)
            view.scene.addAnchor(cameraAnchor)
            defaultDistance = concept.viewerCameraDistance
            resetCamera()
            
            updateSubscription = view.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
                self?.update(deltaTime: Float(event.deltaTime))
            }
        }
        
        func addRoom(to anchor: AnchorEntity, tint: UIColor) {
            var floorMaterial = PhysicallyBasedMaterial()
            floorMaterial.baseColor = .init(tint: UIColor(white: 0.12, alpha: 1))
            floorMaterial.roughness = 0.72
            
            let floor = ModelEntity(mesh: .generateBox(size: [1.9, 0.012, 1.9]), materials: [floorMaterial])
            floor.position = [0, -0.46, 0]
            anchor.addChild(floor)
            
            var wallMaterial = PhysicallyBasedMaterial()
            wallMaterial.baseColor = .init(tint: tint.withAlphaComponent(0.13))
            wallMaterial.blending = .transparent(opacity: 0.13)
            wallMaterial.roughness = 0.9
            
            let rearWall = ModelEntity(mesh: .generateBox(size: [1.9, 1.35, 0.012]), materials: [wallMaterial])
            rearWall.position = [0, 0.2, -0.92]
            anchor.addChild(rearWall)
            
            for x in stride(from: -0.9, through: 0.9, by: 0.18) {
                let line = ModelEntity(mesh: .generateBox(size: [0.004, 0.004, 1.85]), materials: [UnlitMaterial(color: tint.withAlphaComponent(0.18))])
                line.position = [Float(x), -0.447, 0]
                anchor.addChild(line)
            }
            
            for z in stride(from: -0.9, through: 0.9, by: 0.18) {
                let line = ModelEntity(mesh: .generateBox(size: [1.85, 0.004, 0.004]), materials: [UnlitMaterial(color: tint.withAlphaComponent(0.18))])
                line.position = [0, -0.445, Float(z)]
                anchor.addChild(line)
            }
            
            let keyLight = DirectionalLight()
            keyLight.light.intensity = 8000
            keyLight.look(at: .zero, from: [0.6, 1.1, 0.8], relativeTo: nil)
            anchor.addChild(keyLight)
            
            // Fill light from below to eliminate dark underside
            let fillLight = DirectionalLight()
            fillLight.light.intensity = 2000
            fillLight.look(at: .zero, from: [-0.4, -0.6, 0.5], relativeTo: nil)
            anchor.addChild(fillLight)
        }
        
        func loadModel(for concept: QuantumConcept) {
            let modelName = concept.modelAssetName
            let entity = loadEntity(named: modelName) ?? fallbackEntity(for: concept)
            entity.name = "primary_model"
            fit(entity, to: concept)
            modelRoot.addChild(entity)
        }
        
        func addExperimentLayer(for concept: QuantumConcept) {
            switch concept {
            case .superposition:
                let material = UnlitMaterial(color: concept.uiColor.withAlphaComponent(0.85))
                for index in 0..<18 {
                    let particle = ModelEntity(mesh: .generateSphere(radius: 0.012), materials: [material])
                    particle.name = "superposition_particle_\(index)"
                    let angle = Float(index) / 18.0 * 2.0 * .pi
                    let radius: Float = 0.32 + Float(index % 3) * 0.045
                    particle.position = [cos(angle) * radius, sin(angle * 1.7) * 0.18, sin(angle) * radius]
                    modelRoot.addChild(particle)
                }
                
            case .waveParticle:
                let material = UnlitMaterial(color: concept.uiColor)
                for index in 0..<12 {
                    let marker = ModelEntity(mesh: .generateSphere(radius: 0.014), materials: [material])
                    marker.name = "wave_marker_\(index)"
                    marker.position = [-0.46 + Float(index) * 0.08, 0.06, -0.34]
                    modelRoot.addChild(marker)
                }
                
            case .entanglement:
                let left = ModelEntity(mesh: .generateSphere(radius: 0.045), materials: [UnlitMaterial(color: .systemCyan)])
                let right = ModelEntity(mesh: .generateSphere(radius: 0.045), materials: [UnlitMaterial(color: .systemPink)])
                left.name = "entangled_left"
                right.name = "entangled_right"
                left.position = [-0.34, 0.16, 0]
                right.position = [0.34, 0.16, 0]
                modelRoot.addChild(left)
                modelRoot.addChild(right)
                
            case .tesseract:
                let core = ModelEntity(mesh: .generateSphere(radius: 0.045), materials: [UnlitMaterial(color: .white)])
                core.name = "tesseract_energy_core"
                core.position = [0, 0.02, 0]
                modelRoot.addChild(core)
            }
        }
        
        func fit(_ entity: Entity, to concept: QuantumConcept) {
            entity.transform = .identity
            let bounds = entity.visualBounds(relativeTo: nil)
            let extents = bounds.extents
            let largestExtent = max(extents.x, max(extents.y, extents.z))
            let scale = largestExtent > 0 ? concept.viewerFitSize / largestExtent : 1
            entity.scale = [scale, scale, scale]
            
            let scaledCenter = bounds.center * scale
            let scaledHeight = extents.y * scale
            entity.position = [-scaledCenter.x, -scaledCenter.y - (scaledHeight * 0.08), -scaledCenter.z]
        }
        
        func loadEntity(named name: String) -> Entity? {
            if let entity = try? Entity.load(named: name, in: .module) {
                return entity
            }
            
            if let url = Bundle.main.url(forResource: name, withExtension: "usdz"),
               let entity = try? Entity.load(contentsOf: url) {
                return entity
            }
            
            if let url = Bundle.main.url(forResource: name, withExtension: "usdz", subdirectory: "Models"),
               let entity = try? Entity.load(contentsOf: url) {
                return entity
            }
            
            return nil
        }
        
        func fallbackEntity(for concept: QuantumConcept) -> Entity {
            let sphere = ModelEntity(mesh: .generateSphere(radius: 0.18), materials: [UnlitMaterial(color: concept.uiColor)])
            return sphere
        }
        
        func resetCamera() {
            yaw = 0
            pitch = -0.18
            distance = defaultDistance
            applyCameraTransform()
        }
        
        func applyZoomCommand(_ command: Int) {
            guard command != handledZoomCommand else { return }
            let delta = command > handledZoomCommand ? Float(0.85) : Float(1.18)
            distance = min(3.4, max(0.55, distance * delta))
            handledZoomCommand = command
            applyCameraTransform()
        }
        
        func applyInteractionCommand(_ command: Int) {
            guard command != handledInteractionCommand else { return }
            handledInteractionCommand = command
            startInteraction()
        }
        
        func applySlideIndex(_ index: Int) {
            guard index != -1 else { return }
            self.currentSlideIndex = index
            
            switch currentConcept {
            case .superposition:
                for child in modelRoot.children where child.name.starts(with: "superposition_particle") {
                    if index == 0 {
                        child.isEnabled = false
                    } else if index == 1 {
                        child.isEnabled = true
                        child.scale = [1, 1, 1]
                    } else {
                        if child.name == "superposition_particle_0" {
                            child.isEnabled = true
                            child.position = [0.15, 0.05, -0.1]
                            child.scale = [1.5, 1.5, 1.5]
                        } else {
                            child.isEnabled = false
                        }
                    }
                }
            case .waveParticle:
                for i in 0..<12 {
                    if let child = modelRoot.findEntity(named: "wave_marker_\(i)") {
                        if index == 0 {
                            child.isEnabled = false
                        } else if index == 1 {
                            child.isEnabled = true
                            child.position = [-0.46 + Float(i) * 0.08, 0.06, -0.34]
                        } else {
                            child.isEnabled = true
                            let xOffset = Float(i % 3 - 1) * 0.15
                            child.position = [xOffset, 0.06, 0.28]
                        }
                    }
                }
            case .entanglement:
                if let left = modelRoot.findEntity(named: "entangled_left"),
                   let right = modelRoot.findEntity(named: "entangled_right") {
                    if index == 0 {
                        left.position = [-0.06, 0.16, 0]
                        right.position = [0.06, 0.16, 0]
                        left.scale = [1, 1, 1]
                        right.scale = [1, 1, 1]
                    } else if index == 1 {
                        left.position = [-0.34, 0.16, 0]
                        right.position = [0.34, 0.16, 0]
                        left.scale = [1, 1, 1]
                        right.scale = [1, 1, 1]
                    } else {
                        left.position = [-0.34, 0.16, 0]
                        right.position = [0.34, 0.16, 0]
                        left.scale = [1.6, 1.6, 1.6]
                        right.scale = [1.6, 1.6, 1.6]
                    }
                }
            case .tesseract:
                if let core = modelRoot.findEntity(named: "tesseract_energy_core") {
                    if index == 0 {
                        core.isEnabled = false
                    } else if index == 1 {
                        core.isEnabled = true
                        core.scale = [1, 1, 1]
                    } else {
                        core.isEnabled = true
                        core.scale = [2.8, 2.8, 2.8]
                    }
                }
            case nil:
                break
            }
        }
        
        func startInteraction() {
            guard let concept = currentConcept else { return }
            isInteracting = true
            interactionElapsed = 0
            resetExperimentLayer(for: concept)
            
            if concept == .tesseract, let primary = modelRoot.findEntity(named: "primary_model") {
                primary.move(
                    to: Transform(scale: primary.scale * 1.32, rotation: primary.orientation, translation: primary.position),
                    relativeTo: primary.parent,
                    duration: 0.55,
                    timingFunction: .easeInOut
                )
            }
        }
        
        func resetExperimentLayer(for concept: QuantumConcept) {
            switch concept {
            case .tesseract:
                modelRoot.findEntity(named: "tesseract_energy_core")?.scale = [1, 1, 1]
            default:
                break
            }
        }
        
        func applyCameraTransform() {
            let x = sin(yaw) * cos(pitch) * distance
            let y = sin(pitch) * distance + 0.12
            let z = cos(yaw) * cos(pitch) * distance
            camera.position = [x, y, z]
            camera.look(at: [0, -0.08, 0], from: camera.position, relativeTo: nil)
        }
        
        func update(deltaTime: Float) {
            time += deltaTime
            
            if isAnimating {
                modelRoot.orientation *= simd_quatf(angle: 0.24 * deltaTime, axis: [0, 1, 0])
                modelRoot.position.y = sin(time * 1.4) * 0.025
            }
            
            if isInteracting, let concept = currentConcept {
                interactionElapsed += deltaTime
                updateInteraction(for: concept)
                
                if interactionElapsed >= interactionDuration {
                    isInteracting = false
                    if concept == .tesseract, let primary = modelRoot.findEntity(named: "primary_model") {
                        primary.move(
                            to: Transform(scale: primary.scale / 1.32, rotation: primary.orientation, translation: primary.position),
                            relativeTo: primary.parent,
                            duration: 0.45,
                            timingFunction: .easeInOut
                        )
                    }
                }
            }
        }
        
        func updateInteraction(for concept: QuantumConcept) {
            let progress = min(1, interactionElapsed / interactionDuration)
            
            switch concept {
            case .superposition:
                for child in modelRoot.children where child.name.starts(with: "superposition_particle") {
                    child.position *= max(0.95, 1 - (progress * 0.018))
                    child.scale = [1 - progress * 0.45, 1 - progress * 0.45, 1 - progress * 0.45]
                }
                
            case .waveParticle:
                for child in modelRoot.children where child.name.starts(with: "wave_marker") {
                    let offset = Float(abs(child.name.hashValue % 7)) * 0.025
                    child.position.z = -0.34 + progress * 0.78
                    child.position.y = 0.06 + sin((progress * 10) + offset) * 0.09
                }
                
            case .entanglement:
                if let left = modelRoot.findEntity(named: "entangled_left"),
                   let right = modelRoot.findEntity(named: "entangled_right") {
                    let pulse = 1 + sin(progress * .pi * 10) * 0.28
                    left.scale = [pulse, pulse, pulse]
                    right.scale = [pulse, pulse, pulse]
                    left.orientation *= simd_quatf(angle: 0.08, axis: [0, 1, 0])
                    right.orientation *= simd_quatf(angle: -0.08, axis: [0, 1, 0])
                }
                
            case .tesseract:
                if let core = modelRoot.findEntity(named: "tesseract_energy_core") {
                    let pulse = 1 + sin(progress * .pi) * 4
                    core.scale = [pulse, pulse, pulse]
                }
                modelRoot.orientation *= simd_quatf(angle: 0.08, axis: [1, 1, 0])
            }
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            isAnimating.toggle()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        
        @objc func handlePan(_ sender: UIPanGestureRecognizer) {
            guard let view else { return }
            let translation = sender.translation(in: view)
            yaw -= Float(translation.x) * 0.006
            pitch = min(0.55, max(-0.75, pitch + Float(translation.y) * 0.004))
            sender.setTranslation(.zero, in: view)
            applyCameraTransform()
        }
        
        @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
            if sender.state == .began {
                lastScale = sender.scale
            }
            
            let delta = Float(sender.scale / lastScale)
            distance = min(3.4, max(0.55, distance / delta))
            lastScale = sender.scale
            applyCameraTransform()
        }
    }
}
