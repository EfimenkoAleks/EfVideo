//
//  ListCoordinator.swift
//  EfVideo
//
//  Created by user on 21.10.2022.
//

import Foundation
import UIKit

enum ListCoordinatorEvent {
    case detail(VideoModel)
    case back
}

protocol ListCoordinatorProtocol: Coordinator {
    func start()
    func eventOccurred(with type: ListCoordinatorEvent)
}

class ListCoordinator: ListCoordinatorProtocol {
    
    var cildren: [Coordinator] = []
    
    var navigationController: UINavigationController?
    
    func start() {
        let vc = ListViewController()
        vc.coordinator = self
        navigationController?.setViewControllers([vc], animated: false)
    }
}

extension ListCoordinator {
    func eventOccurred(with type: ListCoordinatorEvent) {
        switch type {
        case .detail(let video):
            var detailCoordinator: ListDetailCoordinatorProtocol = ListDetailCoordinator()
            detailCoordinator.navigationController = navigationController
            cildren.append(detailCoordinator)
            detailCoordinator.start(video: video)
            detailCoordinator.handlerBback = { [unowned self] in
                self.eventOccurred(with: .back)
            }
            
        case .back:
            navigationController?.popToRootViewController(animated: true)
            cildren.removeLast()
        }
    }
}
