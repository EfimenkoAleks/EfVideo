//
//  MainCoordinator.swift
//  EfVideo
//
//  Created by user on 16.10.2022.
//

import UIKit

enum MainCoordinatorEvent {
    case detail
}

protocol MainCoordinatorProtocol: Coordinator {
    func start()
}

class MainCoordinator: MainCoordinatorProtocol {
    var cildren: [Coordinator] = []
    
    var navigationController: UINavigationController?
    
    func start() {
        let vc = VideoViewController()
        vc.coordinator = self
        navigationController?.setViewControllers([vc], animated: false)
    }
}

extension MainCoordinator {
    func eventOccurred(with type: MainCoordinatorEvent) {
        switch type {
        case .detail:
            break
        }
    }
}
