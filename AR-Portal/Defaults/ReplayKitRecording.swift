//
//  AR-Portal
//
//  Created by Konstantin on 1/31/19.
//  Copyright © 2019 SKS All rights reserved.
//

import UIKit
import ReplayKit

extension UIViewController {
    func startRecording(completionHandler:@escaping (_ result:Bool) -> Void) {
        if RPScreenRecorder.shared().isAvailable {
            RPScreenRecorder.shared().startRecording() { (error) in
                if error == nil {
                    DispatchQueue.main.async { completionHandler(true) }
                } else {
                    DispatchQueue.main.async { completionHandler(false) }
                }
            }
        } else {
            completionHandler(false)
        }
    }
    
    func stopRecording() {
        RPScreenRecorder.shared().stopRecording { (previewController, error) in
            if let previewController = previewController {
                DispatchQueue.main.async {
                    self.present(previewController, animated: true, completion: nil)
                }
            } else {
                print("error stopping recording (was it running?)")
                
            }
        }
    }
}
