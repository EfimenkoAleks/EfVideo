//
//  ControlButton.swift
//  EfVideo
//
//  Created by user on 16.10.2022.
//

import UIKit

@IBDesignable
final class ControlButton: UIButton {

    var borderWidth: CGFloat = 1.0
    var borderColor = UIColor.white.cgColor

    @IBInspectable var titleText: String? {
        didSet {
            self.setTitle(titleText, for: .normal)
            self.setTitleColor(UIColor.black,for: .normal)
        }
    }

    override init(frame: CGRect){
        super.init(frame: frame)
        self.setTitle("", for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        self.setTitle("", for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    func setup() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width / 2.0
        self.layer.borderColor = borderColor
        self.layer.borderWidth = borderWidth
    }
}
