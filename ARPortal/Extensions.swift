//
//  ARPortal
//
//  Created by Konstantin on 1/31/19.
//  Copyright © 2019 SKS All rights reserved.
//

import Foundation
import SceneKit

extension FloatingPoint {
    var degreesToRadians: Self {
        return self * .pi / 180
    }

    var radiansToDegrees: Self {
        return self * 180 / .pi
    }
}

extension SCNVector3 {
    // from Apples demo APP
    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }

    static func centre() -> SCNVector3 {
        return SCNVector3Make(0, 0, 0)
    }

    static func positionY(angle: Float) -> SCNVector3 {
        return SCNVector3(0, angle.degreesToRadians, 0)
    }
}
