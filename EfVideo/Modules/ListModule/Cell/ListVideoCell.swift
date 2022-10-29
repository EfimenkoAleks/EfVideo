//
//  ListVideoCell.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import UIKit

class ListVideoCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func configure(model: VideoModel) {
        nameLabel.text = model.title
    }
}
