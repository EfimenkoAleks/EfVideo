//
//  MainCoordinator.swift
//  EfVideo
//
//  Created by user on 16.10.2022.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    var cildren: [Coordinator]? = nil
    
    var navigationController: UINavigationController?
    
    func eventOccurred(with type: Event) {
        switch type {
        case .buttonTapped:
            break
        }
    }
    
    func start() {
        var vc: UIViewController & Coordinating = VideoViewController()
        vc.coordinator = self
        navigationController?.setViewControllers([vc], animated: false)
    }
}
