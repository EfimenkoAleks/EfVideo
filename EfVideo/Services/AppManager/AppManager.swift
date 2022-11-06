//
//  AppManager.swift
//  EfVideo
//
//  Created by user on 16.10.2022.
//

import Foundation
import UIKit

class AppManager {
    
    static let shared: AppManager = AppManager()
 
    private var window: UIWindow?
    
    private init() {}
    
    func updateRootVC(_ window: UIWindow?) {
        self.window = window
        let appCoordinator: AppFlowController = AppFlowController()
        window?.rootViewController = appCoordinator
        appCoordinator.setSelectedTab()
    }
}
