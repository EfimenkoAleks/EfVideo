//
//  ListWireframe.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import UIKit

final class ListWireframe {

    public struct ListModule {
        let view: UIViewController & Coordinating
        let viewModel: ListViewModel
        let coordinator: ListCoordinator
    }

    // MARK: - Module setup -

    func createModule(coordinator: ListCoordinator) -> ListModule {
    
        let coordinator = coordinator
        let viewModel = ListViewModel(fetcher: DIContainer.default.listService)
        let view = ListViewController()
        view.viewModel = viewModel
        
        return ListModule(view: view, viewModel: viewModel, coordinator: coordinator)
    }
}
