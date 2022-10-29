//
//  TabBar+Extension.swift
//  EfVideo
//
//  Created by user on 16.10.2022.
//

import UIKit

class TabBar: UITabBar {
    var tabAppearance: (() -> Void)?
    
    override var frame: CGRect {
        didSet {
            if frame != .zero {
                tabAppearance?()
            }
        }
    }
}

