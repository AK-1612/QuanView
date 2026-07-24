import SwiftUI
import SceneKit
import UIKit

@MainActor
struct SceneKitContainer: UIViewRepresentable {
    let concept: QuantumConcept
    @Binding var isAnimating: Bool
    @Binding var resetView: Bool
    @Binding var zoomCommand: Int
    @Binding var interactionCommand: Int
    var slideIndex: Int = -1
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.backgroundColor = UIColor(red: 0.025, green: 0.03, blue: 0.035, alpha: 1)
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.rendersContinuously = true
        
        let scene = QuantumSceneBuilder.buildScene(for: concept)
        scnView.scene = scene
        
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.fieldOfView = 55
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, concept.viewerCameraDistance)
        scene.rootNode.addChildNode(cameraNode)
        scnView.pointOfView = cameraNode
        
        context.coordinator.scnView = scnView
        context.coordinator.currentConcept = concept
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if context.coordinator.currentConcept != concept {
            context.coordinator.currentConcept = concept
            let scene = QuantumSceneBuilder.buildScene(for: concept)
            uiView.scene = scene
            
            let cameraNode = SCNNode()
            let camera = SCNCamera()
            camera.fieldOfView = 55
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(0, 0, concept.viewerCameraDistance)
            scene.rootNode.addChildNode(cameraNode)
            uiView.pointOfView = cameraNode
        }
        
        uiView.isPlaying = isAnimating
        
        if resetView {
            context.coordinator.resetCamera()
            Task { @MainActor in resetView = false }
        }
        
        if zoomCommand != context.coordinator.lastZoomCommand {
            context.coordinator.applyZoom(zoomCommand)
        }
        
        if interactionCommand != context.coordinator.lastInteractionCommand {
            context.coordinator.applyInteraction(interactionCommand)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @MainActor
    final class Coordinator: NSObject {
        var parent: SceneKitContainer
        weak var scnView: SCNView?
        var currentConcept: QuantumConcept?
        var lastZoomCommand = 0
        var lastInteractionCommand = 0
        
        init(_ parent: SceneKitContainer) {
            self.parent = parent
        }
        
        func resetCamera() {
            guard let scnView, let pov = scnView.pointOfView, let concept = currentConcept else { return }
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            pov.position = SCNVector3(0, 0, concept.viewerCameraDistance)
            pov.rotation = SCNVector4(0, 0, 0, 0)
            SCNTransaction.commit()
        }
        
        func applyZoom(_ command: Int) {
            guard command != lastZoomCommand, let scnView, let pov = scnView.pointOfView else { return }
            lastZoomCommand = command
            let delta: Float = (command > 0) ? -0.3 : 0.3
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.3
            pov.position.z = max(0.8, min(4.0, pov.position.z + delta))
            SCNTransaction.commit()
        }
        
        func applyInteraction(_ command: Int) {
            guard command != lastInteractionCommand, let scnView, let scene = scnView.scene else { return }
            lastInteractionCommand = command
            guard let modelRoot = scene.rootNode.childNode(withName: "quantumModelRoot", recursively: true) else { return }
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.8
            let currentRotY = modelRoot.rotation.y
            modelRoot.rotation = SCNVector4(0, 1, 0, currentRotY + Float.pi / 2)
            SCNTransaction.commit()
        }
    }
}
