//
//  Extensions.swift
//  Messenger
//
//  Created by Miguel Angel Gutierrez Maya on 10/04/24.
//

import UIKit

extension UIImage {
    
    var isPortrait: Bool { return size.height > size.width }
    var isLandscape: Bool { return size.width > size.height }
    var breadth: CGFloat { return min(size.width, size.height) }
    var breadhSize: CGSize { return CGSize(width: breadth, height: breadth) }
    var breathRect: CGRect { return CGRect(origin: .zero, size: breadhSize) }
    
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadhSize, false, scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let cgImage = cgImage?.cropping(
            to: CGRect(
                origin: CGPoint(
                    x: isLandscape ? floor((size.width - size.height) / 2) : 0,
                    y: isPortrait ? floor((size.height - size.width) / 2) : 0
                ),
                size: breadhSize
            )
        ) else {
            return nil
        }
        
        UIBezierPath(ovalIn: breathRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breathRect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
