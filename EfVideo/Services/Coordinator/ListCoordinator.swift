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
        let listModule = ListWireframe().createModule(coordinator: self)
        navigationController?.setViewControllers([listModule.view], animated: false)
    }
}

