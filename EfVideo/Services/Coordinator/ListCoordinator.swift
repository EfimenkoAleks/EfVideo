//
//  ListCoordinator.swift
//  EfVideo
//
//  Created by user on 21.10.2022.
//

import Foundation
import UIKit

class ListCoordinator: Coordinator {
    var cildren: [Coordinator]? = nil
    
    var navigationController: UINavigationController?
    
    func eventOccurred(with type: Event) {
        switch type {
        case .buttonTapped:
            break
        }
    }
    
    func start() {
        var vc: UIViewController & Coordinating = ListViewController()
        vc.coordinator = self
        navigationController?.setViewControllers([vc], animated: false)
    }
}

