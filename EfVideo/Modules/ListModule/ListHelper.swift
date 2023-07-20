//
//  ListHelper.swift
//  EfVideo
//
//  Created by user on 29.10.2022.
//

import UIKit
import AVFoundation

class ListHelper {
    
    init() {}
    
    func complexShape(inputView: UIView) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        let constWidth = UIScreen.main.bounds.size.width
        let constHeight = inputView.frame.size.height
        
        path.addLine(to: CGPoint(x: constWidth, y: 0.0))
        path.addLine(to: CGPoint(x: constWidth, y: constHeight - 60))
        path.addQuadCurve(to: CGPoint(x: constWidth - 30, y: constHeight - 30), controlPoint: CGPoint(x: constWidth, y: inputView.frame.size.height - 30))
        path.addLine(to: CGPoint(x: 30, y: constHeight - 30))
        path.addQuadCurve(to: CGPoint(x: 0.0, y: constHeight), controlPoint: CGPoint(x: 0.0, y: constHeight - 30))
        path.addLine(to: CGPoint(x: 0.0, y: 0.0))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        
        inputView.layer.mask = shapeLayer
    }
    
    func imageFromVideo(url: URL, at time: TimeInterval, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let asset = AVURLAsset(url: url)

            let assetIG = AVAssetImageGenerator(asset: asset)
            assetIG.appliesPreferredTrackTransform = true
            assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

            let cmTime = CMTime(seconds: time, preferredTimescale: 60)
            let thumbnailImageRef: CGImage
            do {
                thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
            } catch let error {
                print("Error: \(error)")
                return completion(nil)
            }

            DispatchQueue.main.async {
                completion(UIImage(cgImage: thumbnailImageRef))
            }
        }
    }
}
