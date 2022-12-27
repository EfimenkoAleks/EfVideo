//
//  ListVideoCell.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import UIKit
import AVFoundation

class ListVideoCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func configure(model: VideoModel) {
        nameLabel.text = model.title
//        guard let image = image else { return }
//        imageImageView.image = image
        
        guard let urlStr = model.sources?.first,
        let url = URL(string: urlStr) else { return }
        imageFromVideo(url: url, at: 3) { [weak self] imageOut in
            DispatchQueue.main.async {
                self?.imageImageView.image = imageOut
            }
        }
    }
    
    private func imageFromVideo(url: URL, at time: TimeInterval, completion: @escaping (UIImage?) -> Void) {
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
