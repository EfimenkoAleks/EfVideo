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
    
    let appCoordinator: AppFlowController = AppFlowController()
 
    private var window: UIWindow?
    
    private init() {
    
//        appInfoService.didChangeSettings = { [weak self] in
//            self?.updateHeaders()
//        }
        
    }
    
    func updateRootVC(_ window: UIWindow?) {
        self.window = window
     //   let viewController: AppFlowController = AppFlowController()
        window?.rootViewController = appCoordinator
        appCoordinator.setSelectedTab()
    }
    
//    func loadFirstData() {
//        let photoCollect = BaseFetcher.shared.photoService
//        photoCollect.reload(with: ) { state in
//            if state == .loaded {
//                NotificationCenter.default.post(name: .kNeadUpdateCollection, object: nil)
//            }
//        }
//    }
 
}
