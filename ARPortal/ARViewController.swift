//
//  ARPortal
//
//  Created by Konstantin on 1/31/19.
//  Copyright © 2019 SKS All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController {
    @IBOutlet weak var planeSearchLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!

//        Нужен нам для того что бы понимать обнаружел ли ARKit поверхность для отрисовки
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

//        Логическое значение, которое указывает на то, создает ли ARKit и обновляет ли SceneKit источники света в сцене представления.
        sceneView.automaticallyUpdatesLighting = false

//        Это позволит нам видеть ключевые точки, которые находит ARKit.
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints

//        Вешаем создание портала по тапу на ARSCNView
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(didTapOnSurface))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        Выбор конфигурации сессии зависит от модели устройства, на котором запустили приложение.
//        Крайне важно сделать эту проверку.
//        Иначе, в случае неверной конфигурации, сессия пришлет ошибку и игра не запустится вообще.

        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.isLightEstimationEnabled = true

//        Запускаем сессию когда view Appear
            sceneView.session.run(configuration)
        } else {
            let configuration = AROrientationTrackingConfiguration()
            sceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

//        Не забываем останавливть сессию когда view Disappear
        sceneView.session.pause()
    }

    private func updatePlaneOverlay() {
        DispatchQueue.main.async {
            self.planeSearchLabel.isHidden = self.currentPlane != nil
            if self.planeCount == 0 {
                self.planeSearchLabel.text = Constants.ScanState.scanningText
            } else {
                self.planeSearchLabel.text = Constants.ScanState.detectedText
            }
        }
    }

    private func anyPlaneFrom(location: CGPoint) -> (SCNNode, SCNVector3)? {
//        Выполняем поиск реальных объектов или якорей AR на изображении с камеры, соответствующем точке в представлении SceneKit.
        let results = sceneView.hitTest(location, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        guard results.count > 0, let anchor = results[0].anchor, let node = sceneView.node(for: anchor) else {
            return nil
        }
        
        return (node, SCNVector3.positionFromTransform(results[0].worldTransform))
    }
    
    @objc func didTapOnSurface(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        guard currentPlane == nil, let newPlaneData = anyPlaneFrom(location: location) else {
            return
        }

        currentPlane = newPlaneData.0

        let wallNode = SCNNode()
        wallNode.position = newPlaneData.1
        let sideLength = Constants.Wall.length * 3
        let halfSideLength = sideLength * Constants.half
        let endWallSegmentNode = Nodes.wallSegmentNode(length: sideLength)
        endWallSegmentNode.eulerAngles = SCNVector3.positionY(angle: 90.0)
        endWallSegmentNode.position = SCNVector3(0, Constants.Wall.height * Constants.half, Constants.Wall.length * -1.5)
        wallNode.addChildNode(endWallSegmentNode)
        
        let sideAWallSegmentNode = Nodes.wallSegmentNode(length: sideLength)
        sideAWallSegmentNode.eulerAngles = SCNVector3.positionY(angle: 180.0)
        sideAWallSegmentNode.position = SCNVector3(Constants.Wall.length * -1.5, Constants.Wall.height * 0.5, 0)
        wallNode.addChildNode(sideAWallSegmentNode)
        
        let sideBWallSegmentNode = Nodes.wallSegmentNode(length: sideLength)
        sideBWallSegmentNode.position = SCNVector3(Constants.Wall.length * 1.5, Constants.Wall.height * 0.5, 0)
        wallNode.addChildNode(sideBWallSegmentNode)
        
        let doorSideLength = (sideLength - Constants.Door.width) * Constants.half
        let leftDoorSideNode = Nodes.wallSegmentNode(length: doorSideLength)
        leftDoorSideNode.eulerAngles = SCNVector3.positionY(angle: 270.0)
        leftDoorSideNode.position = SCNVector3(-halfSideLength + Constants.half * doorSideLength, Constants.Wall.height * Constants.half, Constants.Wall.length * 1.5)
        wallNode.addChildNode(leftDoorSideNode)
        
        let rightDoorSideNode = Nodes.wallSegmentNode(length: doorSideLength)
        rightDoorSideNode.eulerAngles = SCNVector3.positionY(angle: 270.0)
        rightDoorSideNode.position = SCNVector3(halfSideLength - Constants.half * doorSideLength, Constants.Wall.height * Constants.half, Constants.Wall.length * 1.5)
        wallNode.addChildNode(rightDoorSideNode)
        
        let aboveDoorNode = Nodes.wallSegmentNode(length: Constants.Door.width, height: Constants.Wall.height -  Constants.Door.height)
        aboveDoorNode.eulerAngles = SCNVector3.positionY(angle: 270.0)
        aboveDoorNode.position = SCNVector3(0, Constants.Wall.height - Constants.Wall.height - Constants.Door.height * Constants.half, Constants.Wall.length * 1.5)
        wallNode.addChildNode(aboveDoorNode)
        
        let floorNode = Nodes.plane(pieces: 3, maskYUpperSide: false)
        floorNode.position = SCNVector3.centre()
        wallNode.addChildNode(floorNode)
        
        let roofNode = Nodes.plane(pieces: 3, maskYUpperSide: true)
        roofNode.position = SCNVector3(0, Constants.Wall.height, 0)
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
        lightNode.position = SCNVector3(newPlaneData.1.x, newPlaneData.1.y + Float(Constants.Door.height), newPlaneData.1.z - Float(Constants.Wall.length))
        lightNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(lightNode)
    }
}

// MARK: - ARSCNViewDelegate
extension ARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        planeCount += 1
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if planeCount > 0 {
            planeCount -= 1
        }
    }
}
