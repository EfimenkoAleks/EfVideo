//
//  TabBarItem.swift
//  EfVideo
//
//  Created by user on 16.10.2022.
//

import UIKit

class TabBarItem: UITabBarItem {
    
    override init() {
        super.init()
    }
    
    convenience init(inTitle: String, inImage: String, inSelectedImage: String, inTag: Int) {
        
        self.init()
        title = inTitle
        image = UIImage(systemName: inImage)
        selectedImage = UIImage(systemName: inSelectedImage)
        tag = inTag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

