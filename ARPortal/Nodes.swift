//
//  ARPortal
//
//  Created by Konstantin on 1/31/19.
//  Copyright © 2019 SKS All rights reserved.
//

import Foundation
import SceneKit

final class Nodes {
    class func plane(pieces:Int, maskYUpperSide:Bool = true) -> SCNNode {
        let maskSegment = SCNBox(width: Constants.Wall.length * CGFloat(pieces), height: Constants.Wall.width, length: Constants.Wall.length * CGFloat(pieces), chamferRadius: 0)
        maskSegment.firstMaterial?.diffuse.contents = UIColor.red
        maskSegment.firstMaterial?.transparency = 0.000001
        maskSegment.firstMaterial?.writesToDepthBuffer = true
        let maskNode = SCNNode(geometry: maskSegment)
        maskNode.renderingOrder = 100
        
        let segment = SCNBox(width: Constants.Wall.length * CGFloat(pieces), height: Constants.Wall.width, length: Constants.Wall.length * CGFloat(pieces), chamferRadius: 0)
        segment.firstMaterial?.diffuse.contents = UIImage(named: Constants.Floor.textureName)
        segment.firstMaterial?.writesToDepthBuffer = true
        segment.firstMaterial?.readsFromDepthBuffer = true

        let node = SCNNode()
        let segmentNode = SCNNode(geometry: segment)
        segmentNode.renderingOrder = 200
        segmentNode.position = SCNVector3(Constants.Wall.width * Constants.half, 0, 0)
        node.addChildNode(segmentNode)

        maskNode.position = SCNVector3(Constants.Wall.width * Constants.half, maskYUpperSide ? Constants.Wall.width : -Constants.Wall.width, 0)
        node.addChildNode(maskNode)

        return node
    }
    
    class func wallSegmentNode(length: CGFloat = Constants.Wall.length, height: CGFloat = Constants.Wall.height, maskXUpperSide:Bool = true) -> SCNNode {

        let node = SCNNode()
        let wallSegment = SCNBox(width: Constants.Wall.width, height: height, length: length, chamferRadius: 0)
        wallSegment.firstMaterial?.diffuse.contents = UIImage(named: Constants.Wall.textureName)
        wallSegment.firstMaterial?.writesToDepthBuffer = true
        wallSegment.firstMaterial?.readsFromDepthBuffer = true
        
        let wallSegmentNode = SCNNode(geometry: wallSegment)
        wallSegmentNode.renderingOrder = 200
        
        node.addChildNode(wallSegmentNode)
        
        let maskingWallSegment = SCNBox(width: Constants.Wall.width, height: height, length: length, chamferRadius: 0)
        maskingWallSegment.firstMaterial?.diffuse.contents = UIColor.red
        maskingWallSegment.firstMaterial?.transparency = 0.000001
        maskingWallSegment.firstMaterial?.writesToDepthBuffer = true
        
        let maskingWallSegmentNode = SCNNode(geometry: maskingWallSegment)
        maskingWallSegmentNode.renderingOrder = 100
        maskingWallSegmentNode.position = SCNVector3(maskXUpperSide ? Constants.Wall.width : -Constants.Wall.width, 0, 0)
        node.addChildNode(maskingWallSegmentNode)
        
        return node
    }
}
