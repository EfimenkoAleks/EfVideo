//
//  ListVideoCell.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import UIKit

class ListVideoCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageImageView: UIImageView!
    
    private var helper: ListHelper = ListHelper()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func configureSecondModule(model: VideoModel) {
        nameLabel.text = model.title
        
        guard let urlStr = model.sources?.first,
        let url = URL(string: urlStr) else { return }
        helper.imageFromVideo(url: url, at: 3) { [weak self] imageOut in
            DispatchQueue.main.async {
                self?.imageImageView.image = imageOut
            }
        }
    }
    
    func configure(model: Videos) {
        imageImageView.image = UIImage()
        
        let url = URL(string: model.url)
        let lastComponent = url?.lastPathComponent ?? "None"
        let replaceDash = lastComponent.replacingOccurrences(of: "-", with: " ")
        let replaceNumbers = replaceDash.components(separatedBy: CharacterSet.decimalDigits).joined()
        nameLabel.text = replaceNumbers
        
        guard let url = URL(string: model.videoFiles[1].link) else { return }
        helper.imageFromVideo(url: url, at: 3) { [weak self] imageOut in
            DispatchQueue.main.async {
                self?.imageImageView.image = imageOut
            }
        }
    }
}
