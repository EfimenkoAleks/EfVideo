//
//  TableViewCell+Extension.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import UIKit

protocol ReusableCell {
    static var nib: UINib { get }
}

extension ReusableCell {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}
