//
//  ListDetailCoordinator.swift
//  EfVideo
//
//  Created by user on 05.11.2022.
//

import UIKit

protocol ListDetailCoordinatorProtocol: Coordinator {
    func start(video: VideoModel?)
    var handlerBback: (() -> Void)? { get set }
}

class ListDetailCoordinator: ListDetailCoordinatorProtocol {
    var cildren: [Coordinator] = []
    
    var navigationController: UINavigationController?
    var handlerBback: (() -> Void)?
    
    func start(video: VideoModel?) {
        let vc = ListDetailViewController(video: video)
        vc.coordinator = self
        navigationController?.pushViewController(vc, animated: true)
    }
}
