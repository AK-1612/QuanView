import Foundation
import SceneKit
import UIKit

@MainActor
final class QuantumSceneBuilder {
    
    static func buildScene(for concept: QuantumConcept) -> SCNScene {
        let scene = SCNScene()
        
        // Base environment lighting
        let ambientNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 0.15, alpha: 1.0)
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        let keyLightNode = SCNNode()
        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.color = UIColor(white: 0.85, alpha: 1.0)
        keyLightNode.light = keyLight
        keyLightNode.position = SCNVector3(x: 5, y: 10, z: 8)
        keyLightNode.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(keyLightNode)
        
        let omniLightNode = SCNNode()
        let omniLight = SCNLight()
        omniLight.type = .omni
        omniLight.color = concept.uiColor
        omniLight.intensity = 800
        omniLightNode.light = omniLight
        omniLightNode.position = SCNVector3(x: 0, y: 2, z: 2)
        scene.rootNode.addChildNode(omniLightNode)
        
        // Build concept-specific procedural 3D model
        let modelNode = SCNNode()
        modelNode.name = "quantumModelRoot"
        
        switch concept {
        case .superposition:
            buildSuperpositionScene(in: modelNode)
        case .waveParticle:
            buildWaveParticleScene(in: modelNode)
        case .entanglement:
            buildEntanglementScene(in: modelNode)
        case .tesseract:
            buildTesseractScene(in: modelNode)
        case .tunneling:
            buildTunnelingScene(in: modelNode)
        case .sternGerlach:
            buildSternGerlachScene(in: modelNode)
        case .teleportation:
            buildTeleportationScene(in: modelNode)
        case .superconductivity:
            buildSuperconductivityScene(in: modelNode)
        }
        
        scene.rootNode.addChildNode(modelNode)
        return scene
    }
    
    // MARK: - 1. Superposition
    private static func buildSuperpositionScene(in root: SCNNode) {
        // Nucleus
        let nucleus = SCNNode(geometry: SCNSphere(radius: 0.12))
        let nucleusMat = SCNMaterial()
        nucleusMat.diffuse.contents = UIColor.systemPink
        nucleusMat.emission.contents = UIColor.systemPink
        nucleus.geometry?.firstMaterial = nucleusMat
        root.addChildNode(nucleus)
        
        // Orbital Shell 1 (s-orbital sphere)
        let sOrbital = SCNNode(geometry: SCNSphere(radius: 0.35))
        let sMat = SCNMaterial()
        sMat.diffuse.contents = UIColor.systemCyan.withAlphaComponent(0.25)
        sMat.transparency = 0.35
        sMat.isDoubleSided = true
        sOrbital.geometry?.firstMaterial = sMat
        root.addChildNode(sOrbital)
        
        // Orbital Shell 2 (p_z lobes - dumbbell)
        for dir in [-1.0, 1.0] {
            let lobe = SCNNode(geometry: SCNSphere(radius: 0.28))
            lobe.position = SCNVector3(0, Float(dir * 0.45), 0)
            lobe.scale = SCNVector3(0.7, 1.2, 0.7)
            let lobeMat = SCNMaterial()
            lobeMat.diffuse.contents = UIColor.cyan.withAlphaComponent(0.35)
            lobeMat.emission.contents = UIColor.cyan.withAlphaComponent(0.2)
            lobeMat.isDoubleSided = true
            lobe.geometry?.firstMaterial = lobeMat
            root.addChildNode(lobe)
        }
        
        // Electron Cloud Particle Swarm
        let particleNode = SCNNode()
        for _ in 0..<120 {
            let p = SCNNode(geometry: SCNSphere(radius: 0.015))
            let u = Float.random(in: -1...1)
            let theta = Float.random(in: 0...(2 * .pi))
            let r = Float.random(in: 0.2...0.7)
            let x = r * sqrt(1 - u * u) * cos(theta)
            let y = r * sqrt(1 - u * u) * sin(theta)
            let z = r * u
            p.position = SCNVector3(x, y, z)
            
            let pMat = SCNMaterial()
            pMat.diffuse.contents = UIColor.cyan
            pMat.emission.contents = UIColor.cyan
            p.geometry?.firstMaterial = pMat
            
            let pulse = CABasicAnimation(keyPath: "opacity")
            pulse.fromValue = 0.2
            pulse.toValue = 1.0
            pulse.duration = CFTimeInterval.random(in: 0.8...1.8)
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            p.addAnimation(pulse, forKey: "pulse")
            
            particleNode.addChildNode(p)
        }
        root.addChildNode(particleNode)
        
        // Orbital rotation
        let rotate = CABasicAnimation(keyPath: "rotation")
        rotate.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
        rotate.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotate.duration = 10.0
        rotate.repeatCount = .infinity
        root.addAnimation(rotate, forKey: "orbitRotate")
    }
    
    // MARK: - 2. Wave-Particle Duality
    private static func buildWaveParticleScene(in root: SCNNode) {
        // Double slit barrier plate
        let barrier = SCNNode(geometry: SCNBox(width: 1.2, height: 0.8, length: 0.05, chamferRadius: 0.01))
        let barrierMat = SCNMaterial()
        barrierMat.diffuse.contents = UIColor.darkGray
        barrier.geometry?.firstMaterial = barrierMat
        barrier.position = SCNVector3(0, 0, -0.2)
        root.addChildNode(barrier)
        
        // Slit cutouts representation (left slit & right slit glow bars)
        for xOffset in [-0.15, 0.15] {
            let slitGlow = SCNNode(geometry: SCNBox(width: 0.04, height: 0.5, length: 0.06, chamferRadius: 0))
            slitGlow.position = SCNVector3(Float(xOffset), 0, -0.2)
            let glowMat = SCNMaterial()
            glowMat.diffuse.contents = UIColor.systemTeal
            glowMat.emission.contents = UIColor.systemTeal
            slitGlow.geometry?.firstMaterial = glowMat
            root.addChildNode(slitGlow)
        }
        
        // Detection Screen
        let screen = SCNNode(geometry: SCNBox(width: 1.4, height: 0.9, length: 0.02, chamferRadius: 0))
        screen.position = SCNVector3(0, 0, 0.6)
        let screenMat = SCNMaterial()
        screenMat.diffuse.contents = UIColor(white: 0.1, alpha: 1.0)
        screen.geometry?.firstMaterial = screenMat
        root.addChildNode(screen)
        
        // Interference pattern lines on screen
        for i in -5...5 {
            let intensity = cos(Float(i) * 0.6) * 0.5 + 0.5
            let fringe = SCNNode(geometry: SCNBox(width: 0.06, height: 0.8, length: 0.025, chamferRadius: 0))
            fringe.position = SCNVector3(Float(i) * 0.12, 0, 0.61)
            let fringeMat = SCNMaterial()
            let col = UIColor.systemTeal.withAlphaComponent(CGFloat(intensity))
            fringeMat.diffuse.contents = col
            fringeMat.emission.contents = col
            fringe.geometry?.firstMaterial = fringeMat
            root.addChildNode(fringe)
        }
        
        // Incoming wave rings
        for ringIdx in 0..<5 {
            let ring = SCNNode(geometry: SCNTorus(ringRadius: CGFloat(0.1 + Double(ringIdx) * 0.15), pipeRadius: 0.01))
            ring.position = SCNVector3(0, 0, Float(-0.7 + Double(ringIdx) * 0.1))
            ring.rotation = SCNVector4(1, 0, 0, Float.pi / 2)
            let ringMat = SCNMaterial()
            ringMat.diffuse.contents = UIColor.systemTeal.withAlphaComponent(0.6)
            ringMat.emission.contents = UIColor.systemTeal
            ring.geometry?.firstMaterial = ringMat
            root.addChildNode(ring)
        }
    }
    
    // MARK: - 3. Quantum Entanglement
    private static func buildEntanglementScene(in root: SCNNode) {
        // Particle A
        let nodeA = SCNNode(geometry: SCNSphere(radius: 0.22))
        nodeA.position = SCNVector3(-0.6, 0, 0)
        let matA = SCNMaterial()
        matA.diffuse.contents = UIColor.systemCyan
        matA.emission.contents = UIColor.systemCyan.withAlphaComponent(0.6)
        nodeA.geometry?.firstMaterial = matA
        root.addChildNode(nodeA)
        
        // Particle B
        let nodeB = SCNNode(geometry: SCNSphere(radius: 0.22))
        nodeB.position = SCNVector3(0.6, 0, 0)
        let matB = SCNMaterial()
        matB.diffuse.contents = UIColor.systemCyan
        matB.emission.contents = UIColor.systemCyan.withAlphaComponent(0.6)
        nodeB.geometry?.firstMaterial = matB
        root.addChildNode(nodeB)
        
        // Entangled correlation beam (cylinder connection)
        let beam = SCNNode(geometry: SCNCylinder(radius: 0.02, height: 1.2))
        beam.position = SCNVector3(0, 0, 0)
        beam.rotation = SCNVector4(0, 0, 1, Float.pi / 2)
        let beamMat = SCNMaterial()
        beamMat.diffuse.contents = UIColor.cyan.withAlphaComponent(0.7)
        beamMat.emission.contents = UIColor.cyan
        beam.geometry?.firstMaterial = beamMat
        root.addChildNode(beam)
        
        // Spin arrows for particles
        let arrowA = SCNNode(geometry: SCNCylinder(radius: 0.015, height: 0.35))
        arrowA.position = SCNVector3(-0.6, 0.3, 0)
        let arrowMatA = SCNMaterial()
        arrowMatA.diffuse.contents = UIColor.green
        arrowA.geometry?.firstMaterial = arrowMatA
        root.addChildNode(arrowA)
        
        let arrowB = SCNNode(geometry: SCNCylinder(radius: 0.015, height: 0.35))
        arrowB.position = SCNVector3(0.6, -0.3, 0)
        let arrowMatB = SCNMaterial()
        arrowMatB.diffuse.contents = UIColor.red
        arrowB.geometry?.firstMaterial = arrowMatB
        root.addChildNode(arrowB)
        
        // Synchronized spin rotation
        let spinA = CABasicAnimation(keyPath: "rotation")
        spinA.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
        spinA.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        spinA.duration = 4.0
        spinA.repeatCount = .infinity
        nodeA.addAnimation(spinA, forKey: "spinA")
        nodeB.addAnimation(spinA, forKey: "spinB")
    }
    
    // MARK: - 4. Zero-Point Tesseract
    private static func buildTesseractScene(in root: SCNNode) {
        // Outer Cube
        let outerCube = SCNNode(geometry: SCNBox(width: 0.8, height: 0.8, length: 0.8, chamferRadius: 0.02))
        let outerMat = SCNMaterial()
        outerMat.diffuse.contents = UIColor.clear
        outerMat.isDoubleSided = true
        outerCube.geometry?.firstMaterial = outerMat
        
        // Wireframe edges for outer cube
        let outerWire = createWireframeCube(size: 0.8, color: UIColor.systemMint)
        root.addChildNode(outerWire)
        
        // Inner Cube
        let innerWire = createWireframeCube(size: 0.4, color: UIColor.cyan)
        root.addChildNode(innerWire)
        
        // Connecting struts between inner and outer corners (8 corners)
        let corners: [SCNVector3] = [
            SCNVector3(-0.4, -0.4, -0.4), SCNVector3(0.4, -0.4, -0.4),
            SCNVector3(-0.4, 0.4, -0.4), SCNVector3(0.4, 0.4, -0.4),
            SCNVector3(-0.4, -0.4, 0.4), SCNVector3(0.4, -0.4, 0.4),
            SCNVector3(-0.4, 0.4, 0.4), SCNVector3(0.4, 0.4, 0.4)
        ]
        
        for corner in corners {
            let innerCorner = SCNVector3(corner.x * 0.5, corner.y * 0.5, corner.z * 0.5)
            let strut = createLineNode(from: innerCorner, to: corner, color: UIColor.systemTeal.withAlphaComponent(0.8))
            root.addChildNode(strut)
        }
        
        // Zero-point fluctuation core sphere
        let core = SCNNode(geometry: SCNSphere(radius: 0.12))
        let coreMat = SCNMaterial()
        coreMat.diffuse.contents = UIColor.white
        coreMat.emission.contents = UIColor.cyan
        core.geometry?.firstMaterial = coreMat
        root.addChildNode(core)
        
        // 4D Rotation animation (XW / YZ plane projection rotation)
        let rot4D = CABasicAnimation(keyPath: "rotation")
        rot4D.fromValue = NSValue(scnVector4: SCNVector4(1, 1, 0, 0))
        rot4D.toValue = NSValue(scnVector4: SCNVector4(1, 1, 0, Float.pi * 2))
        rot4D.duration = 8.0
        rot4D.repeatCount = .infinity
        root.addAnimation(rot4D, forKey: "rot4D")
    }
    
    // MARK: - 5. Quantum Tunneling
    private static func buildTunnelingScene(in root: SCNNode) {
        // Potential Barrier Box
        let barrier = SCNNode(geometry: SCNBox(width: 0.15, height: 0.8, length: 0.8, chamferRadius: 0.01))
        barrier.position = SCNVector3(0, 0, 0)
        let barrierMat = SCNMaterial()
        barrierMat.diffuse.contents = UIColor.purple.withAlphaComponent(0.4)
        barrierMat.emission.contents = UIColor.purple.withAlphaComponent(0.2)
        barrierMat.isDoubleSided = true
        barrier.geometry?.firstMaterial = barrierMat
        root.addChildNode(barrier)
        
        // Incident Wave Packet (Left)
        let incident = SCNNode(geometry: SCNSphere(radius: 0.18))
        incident.position = SCNVector3(-0.55, 0, 0)
        let incMat = SCNMaterial()
        incMat.diffuse.contents = UIColor.systemIndigo
        incMat.emission.contents = UIColor.systemIndigo.withAlphaComponent(0.5)
        incident.geometry?.firstMaterial = incMat
        root.addChildNode(incident)
        
        // Transmitted Wave Packet (Right - Smaller/Attenuated)
        let transmitted = SCNNode(geometry: SCNSphere(radius: 0.10))
        transmitted.position = SCNVector3(0.55, 0, 0)
        let transMat = SCNMaterial()
        transMat.diffuse.contents = UIColor.cyan.withAlphaComponent(0.7)
        transMat.emission.contents = UIColor.cyan.withAlphaComponent(0.4)
        transmitted.geometry?.firstMaterial = transMat
        root.addChildNode(transmitted)
        
        // Exponential Wave Decay Line across barrier
        let decayLine = createLineNode(from: SCNVector3(-0.55, 0, 0), to: SCNVector3(0.55, 0, 0), color: UIColor.cyan)
        root.addChildNode(decayLine)
    }
    
    // MARK: - 6. Stern-Gerlach Experiment
    private static func buildSternGerlachScene(in root: SCNNode) {
        // North Magnet Pole Piece (Apex shape - North top)
        let northPole = SCNNode(geometry: SCNPyramid(width: 0.5, height: 0.4, length: 0.6))
        northPole.position = SCNVector3(0, 0.45, 0)
        northPole.rotation = SCNVector4(1, 0, 0, Float.pi)
        let northMat = SCNMaterial()
        northMat.diffuse.contents = UIColor.systemRed
        northPole.geometry?.firstMaterial = northMat
        root.addChildNode(northPole)
        
        // South Magnet Pole Piece (Flat/Concave bottom)
        let southPole = SCNNode(geometry: SCNBox(width: 0.5, height: 0.2, length: 0.6, chamferRadius: 0.02))
        southPole.position = SCNVector3(0, -0.45, 0)
        let southMat = SCNMaterial()
        southMat.diffuse.contents = UIColor.systemBlue
        southPole.geometry?.firstMaterial = southMat
        root.addChildNode(southPole)
        
        // Incident Beam line (Left to center)
        let incidentBeam = createLineNode(from: SCNVector3(-0.8, 0, 0), to: SCNVector3(-0.1, 0, 0), color: UIColor.white)
        root.addChildNode(incidentBeam)
        
        // Split Path 1: Spin Up (+1/2 deflection up)
        let spinUpBeam = createLineNode(from: SCNVector3(-0.1, 0, 0), to: SCNVector3(0.8, 0.25, 0), color: UIColor.systemPink)
        root.addChildNode(spinUpBeam)
        
        // Split Path 2: Spin Down (-1/2 deflection down)
        let spinDownBeam = createLineNode(from: SCNVector3(-0.1, 0, 0), to: SCNVector3(0.8, -0.25, 0), color: UIColor.systemCyan)
        root.addChildNode(spinDownBeam)
        
        // Detector Plate on the right
        let detector = SCNNode(geometry: SCNBox(width: 0.03, height: 0.7, length: 0.5, chamferRadius: 0))
        detector.position = SCNVector3(0.8, 0, 0)
        let detMat = SCNMaterial()
        detMat.diffuse.contents = UIColor.darkGray
        detector.geometry?.firstMaterial = detMat
        root.addChildNode(detector)
    }
    
    // MARK: - 7. Quantum Teleportation
    private static func buildTeleportationScene(in root: SCNNode) {
        // Alice Node
        let aliceNode = SCNNode(geometry: SCNSphere(radius: 0.18))
        aliceNode.position = SCNVector3(-0.6, 0.2, 0)
        let aliceMat = SCNMaterial()
        aliceMat.diffuse.contents = UIColor.systemPurple
        aliceMat.emission.contents = UIColor.systemPurple.withAlphaComponent(0.4)
        aliceNode.geometry?.firstMaterial = aliceMat
        root.addChildNode(aliceNode)
        
        // Bob Node
        let bobNode = SCNNode(geometry: SCNSphere(radius: 0.18))
        bobNode.position = SCNVector3(0.6, 0.2, 0)
        let bobMat = SCNMaterial()
        bobMat.diffuse.contents = UIColor.systemGreen
        bobMat.emission.contents = UIColor.systemGreen.withAlphaComponent(0.4)
        bobNode.geometry?.firstMaterial = bobMat
        root.addChildNode(bobNode)
        
        // EPR Source Node (Center bottom)
        let eprNode = SCNNode(geometry: SCNSphere(radius: 0.12))
        eprNode.position = SCNVector3(0, -0.35, 0)
        let eprMat = SCNMaterial()
        eprMat.diffuse.contents = UIColor.yellow
        eprMat.emission.contents = UIColor.orange
        eprNode.geometry?.firstMaterial = eprMat
        root.addChildNode(eprNode)
        
        // Entangled Channels (EPR to Alice, EPR to Bob)
        let channelA = createLineNode(from: SCNVector3(0, -0.35, 0), to: SCNVector3(-0.6, 0.2, 0), color: UIColor.orange)
        let channelB = createLineNode(from: SCNVector3(0, -0.35, 0), to: SCNVector3(0.6, 0.2, 0), color: UIColor.orange)
        root.addChildNode(channelA)
        root.addChildNode(channelB)
        
        // Classical Communication Channel (Alice to Bob)
        let classicalChannel = createLineNode(from: SCNVector3(-0.6, 0.2, 0), to: SCNVector3(0.6, 0.2, 0), color: UIColor.cyan)
        root.addChildNode(classicalChannel)
    }
    
    // MARK: - 8. Superconductivity & Meissner Effect
    private static func buildSuperconductivityScene(in root: SCNNode) {
        // Superconducting Ceramic Disk Base
        let disk = SCNNode(geometry: SCNCylinder(radius: 0.6, height: 0.12))
        disk.position = SCNVector3(0, -0.35, 0)
        let diskMat = SCNMaterial()
        diskMat.diffuse.contents = UIColor.darkGray
        diskMat.specular.contents = UIColor.cyan
        disk.geometry?.firstMaterial = diskMat
        root.addChildNode(disk)
        
        // Levitating Permanent Magnet (Cube)
        let magnet = SCNNode(geometry: SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.02))
        magnet.position = SCNVector3(0, 0.25, 0)
        let magMat = SCNMaterial()
        magMat.diffuse.contents = UIColor.systemRed
        magMat.emission.contents = UIColor.systemRed.withAlphaComponent(0.3)
        magnet.geometry?.firstMaterial = magMat
        root.addChildNode(magnet)
        
        // Expelled Magnetic Field Lines (Curved torus rings around disk)
        for i in 1...3 {
            let fieldRing = SCNNode(geometry: SCNTorus(ringRadius: CGFloat(0.35 + Double(i) * 0.15), pipeRadius: 0.012))
            fieldRing.position = SCNVector3(0, Float(0.25 - Double(i) * 0.15), 0)
            let ringMat = SCNMaterial()
            ringMat.diffuse.contents = UIColor.systemCyan.withAlphaComponent(0.7)
            ringMat.emission.contents = UIColor.cyan
            fieldRing.geometry?.firstMaterial = ringMat
            root.addChildNode(fieldRing)
        }
        
        // Bobbing levitation animation
        let levitate = CABasicAnimation(keyPath: "position.y")
        levitate.fromValue = 0.22
        levitate.toValue = 0.28
        levitate.duration = 1.8
        levitate.autoreverses = true
        levitate.repeatCount = .infinity
        magnet.addAnimation(levitate, forKey: "levitate")
    }
    
    // MARK: - Helper Utilities
    private static func createWireframeCube(size: Float, color: UIColor) -> SCNNode {
        let node = SCNNode()
        let h = size / 2.0
        let corners: [SCNVector3] = [
            SCNVector3(-h, -h, -h), SCNVector3(h, -h, -h), SCNVector3(h, h, -h), SCNVector3(-h, h, -h),
            SCNVector3(-h, -h, h), SCNVector3(h, -h, h), SCNVector3(h, h, h), SCNVector3(-h, h, h)
        ]
        
        let edges = [
            (0,1), (1,2), (2,3), (3,0),
            (4,5), (5,6), (6,7), (7,4),
            (0,4), (1,5), (2,6), (3,7)
        ]
        
        for (i, j) in edges {
            let line = createLineNode(from: corners[i], to: corners[j], color: color)
            node.addChildNode(line)
        }
        return node
    }
    
    private static func createLineNode(from v1: SCNVector3, to v2: SCNVector3, color: UIColor) -> SCNNode {
        let dx = v2.x - v1.x
        let dy = v2.y - v1.y
        let dz = v2.z - v1.z
        let distance = sqrt(dx * dx + dy * dy + dz * dz)
        
        let cylinder = SCNCylinder(radius: 0.008, height: CGFloat(distance))
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        mat.emission.contents = color
        cylinder.firstMaterial = mat
        
        let node = SCNNode(geometry: cylinder)
        node.position = SCNVector3((v1.x + v2.x) / 2.0, (v1.y + v2.y) / 2.0, (v1.z + v2.z) / 2.0)
        
        // Orient cylinder towards v2
        let yVector = SCNVector3(0, 1, 0)
        let dir = SCNVector3(dx / distance, dy / distance, dz / distance)
        let axis = SCNVector3(yVector.z * dir.y - yVector.y * dir.z, yVector.x * dir.z - yVector.z * dir.x, yVector.y * dir.x - yVector.x * dir.y)
        let angle = acos(yVector.x * dir.x + yVector.y * dir.y + yVector.z * dir.z)
        
        if axis.x != 0 || axis.y != 0 || axis.z != 0 {
            node.rotation = SCNVector4(axis.x, axis.y, axis.z, angle)
        }
        
        return node
    }
}
