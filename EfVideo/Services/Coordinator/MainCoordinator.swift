//
//  MainCoordinator.swift
//  EfVideo
//
//  Created by user on 16.10.2022.
//

import UIKit

enum MainCoordinatorEvent {
    case detail(VideoModel)
    case back
}

protocol MainCoordinatorProtocol: Coordinator {
    func start()
    func eventOccurred(with type: MainCoordinatorEvent)
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
