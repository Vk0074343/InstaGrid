//
//  Extensions.swift
//  ImageGrid
//
//  Created by Vaibhav Khatri on 30/04/24.
//

import Foundation
import UIKit

extension UIImage {
    func centerCroppedToSize(_ size: CGSize) -> UIImage {
        let cgImage = self.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgImage)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgWidth: CGFloat = CGFloat(contextImage.size.width)
        var cgHeight: CGFloat = CGFloat(contextImage.size.height)
        
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgWidth = contextSize.height
            cgHeight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgWidth = contextSize.width
            cgHeight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgWidth, height: cgHeight)
        let imageRef: CGImage = cgImage.cropping(to: rect)!
        let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
}
