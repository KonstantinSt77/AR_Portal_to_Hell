//
//  AR-Portal
//
//  Created by Konstantin on 1/31/19.
//  Copyright © 2019 SKS All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    @IBOutlet weak var planeSearchLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!

    var planeCount = 0 {
        didSet {
            updatePlaneOverlay()
        }
    }
    var currentPlane: SCNNode? {
        didSet {
            updatePlaneOverlay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = false
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(didTap))
        sceneView.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }

    private func updatePlaneOverlay() {
        DispatchQueue.main.async {
            self.planeSearchLabel.isHidden = self.currentPlane != nil
            if self.planeCount == 0 {
                self.planeSearchLabel.text = "Move around..."
            } else {
                self.planeSearchLabel.text = "Tap on surface!"
            }
        }
    }
    
    private func anyPlaneFrom(location:CGPoint) -> (SCNNode, SCNVector3)? {
        let results = sceneView.hitTest(location, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        guard results.count > 0, let anchor = results[0].anchor, let node = sceneView.node(for: anchor) else {
            return nil
        }
        
        return (node, SCNVector3.positionFromTransform(results[0].worldTransform))
    }
    
    @objc func didTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        guard currentPlane == nil, let newPlaneData = anyPlaneFrom(location: location) else {
            return
        }

        currentPlane = newPlaneData.0

        let wallNode = SCNNode()
        wallNode.position = newPlaneData.1
        let sideLength = Nodes.WALL_LENGTH * 3
        let halfSideLength = sideLength * 0.5
        let endWallSegmentNode = Nodes.wallSegmentNode(length: sideLength, maskXUpperSide: true)
        endWallSegmentNode.eulerAngles = SCNVector3(0, 90.0.degreesToRadians, 0)
        endWallSegmentNode.position = SCNVector3(0, Float(Nodes.WALL_HEIGHT * 0.5), Float(Nodes.WALL_LENGTH) * -1.5)
        wallNode.addChildNode(endWallSegmentNode)
        
        let sideAWallSegmentNode = Nodes.wallSegmentNode(length: sideLength, maskXUpperSide: true)
        sideAWallSegmentNode.eulerAngles = SCNVector3(0, 180.0.degreesToRadians, 0)
        sideAWallSegmentNode.position = SCNVector3(Float(Nodes.WALL_LENGTH) * -1.5, Float(Nodes.WALL_HEIGHT * 0.5), 0)
        wallNode.addChildNode(sideAWallSegmentNode)
        
        let sideBWallSegmentNode = Nodes.wallSegmentNode(length: sideLength, maskXUpperSide: true)
        sideBWallSegmentNode.position = SCNVector3(Float(Nodes.WALL_LENGTH) * 1.5, Float(Nodes.WALL_HEIGHT * 0.5), 0)
        wallNode.addChildNode(sideBWallSegmentNode)
        
        let doorSideLength = (sideLength - Nodes.DOOR_WIDTH) * 0.5
        let leftDoorSideNode = Nodes.wallSegmentNode(length: doorSideLength, maskXUpperSide: true)
        leftDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        leftDoorSideNode.position = SCNVector3(Float(-halfSideLength + 0.5 * doorSideLength), Float(Nodes.WALL_HEIGHT) * Float(0.5), Float(Nodes.WALL_LENGTH) * 1.5)
        wallNode.addChildNode(leftDoorSideNode)
        
        let rightDoorSideNode = Nodes.wallSegmentNode(length: doorSideLength, maskXUpperSide: true)
        rightDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        rightDoorSideNode.position = SCNVector3(Float(halfSideLength - 0.5 * doorSideLength), Float(Nodes.WALL_HEIGHT) * Float(0.5), Float(Nodes.WALL_LENGTH) * 1.5)
        wallNode.addChildNode(rightDoorSideNode)
        
        let aboveDoorNode = Nodes.wallSegmentNode(length: Nodes.DOOR_WIDTH, height: Nodes.WALL_HEIGHT -  Nodes.DOOR_HEIGHT)
        aboveDoorNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        aboveDoorNode.position = SCNVector3(0, Float(Nodes.WALL_HEIGHT) - Float(Nodes.WALL_HEIGHT - Nodes.DOOR_HEIGHT) * 0.5, Float(Nodes.WALL_LENGTH) * 1.5)
        wallNode.addChildNode(aboveDoorNode)
        
        let floorNode = Nodes.plane(pieces: 3, maskYUpperSide: false)
        floorNode.position = SCNVector3(0, 0, 0)
        wallNode.addChildNode(floorNode)
        
        let roofNode = Nodes.plane(pieces: 3, maskYUpperSide: true)
        roofNode.position = SCNVector3(0, Float(Nodes.WALL_HEIGHT), 0)
        wallNode.addChildNode(roofNode)
        
        sceneView.scene.rootNode.addChildNode(wallNode)

        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.diffuse.contents = UIColor.white
        floor.firstMaterial?.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        let floorShadowNode = SCNNode(geometry:floor)
        floorShadowNode.position = newPlaneData.1
        sceneView.scene.rootNode.addChildNode(floorShadowNode)

        let light = SCNLight()
        light.type = .spot
        light.spotInnerAngle = 70
        light.spotOuterAngle = 120
        light.zNear = 0.00001
        light.zFar = 5
        light.castsShadow = true
        light.shadowRadius = 200
        light.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        light.shadowMode = .deferred
        let constraint = SCNLookAtConstraint(target: floorShadowNode)
        constraint.isGimbalLockEnabled = true

        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(newPlaneData.1.x, newPlaneData.1.y + Float(Nodes.DOOR_HEIGHT), newPlaneData.1.z - Float(Nodes.WALL_LENGTH))
        lightNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(lightNode)
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        planeCount += 1
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if planeCount > 0 {
            planeCount -= 1
        }
    }
}
