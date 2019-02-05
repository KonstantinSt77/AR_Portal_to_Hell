//
//  Constants.swift
//  ARPortal
//
//  Created by Konstantin on 2/5/19.
//  Copyright © 2019 Silicon.dk ApS. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    struct Wall {
        static let width: CGFloat = 0.02
        static let height: CGFloat = 2.2
        static let length: CGFloat = 1
        static let textureName = "hellWall2.jpg"
    }

    struct Door {
        static let width: CGFloat = 0.6
        static let height: CGFloat = 1.5
    }

    struct Floor {
        static let textureName = "hellFloor2.jpg"
    }

    struct ScanState {
        static let scanningText = "Move around..."
        static let detectedText = "Tap on surface!"
    }

    static let half: CGFloat = 0.5
}
