//
//  AppFlowController.swift
//  EfVideo
//
//  Created by user on 16.10.2022.
//

import UIKit

class AppFlowController: UIViewController {
    
    private struct TabBarItemAppearance {
        static var firstControllerTitle: String = "Server"
        static var secondControllerTitle: String = "Phone"
        static var firstControllerImage: String = "tray"
        static var secondControllerImage: String = "book"
        static var firstSelectedControllerImage: String = "tray.fill"
        static var secondSelectedControllerImage: String = "book.fill"
    }

    var tabBarItemTypes: [TabBarItemType] {
        return []
    }
    
    enum TabBarItemType: Int {
        case first
        case second
        
        var item: TabBarItem {
            switch self {
            case .first:
                return TabBarItem(
                    inTitle: TabBarItemAppearance.firstControllerTitle,
                    inImage: TabBarItemAppearance.firstControllerImage,
                    inSelectedImage: TabBarItemAppearance.firstSelectedControllerImage,
                    inTag: self.rawValue
                )
                
            case .second:
                return TabBarItem(
                    inTitle: TabBarItemAppearance.secondControllerTitle,
                    inImage: TabBarItemAppearance.secondControllerImage,
                    inSelectedImage: TabBarItemAppearance.secondSelectedControllerImage,
                    inTag: self.rawValue
                )
            }
        }
    }
    
    var availableTabBarItemTypes: [TabBarItemType] {
        return [.first, .second]
    }
    private var embedTabBar: TabBar = TabBar()
    private var embedViewControllers: [TabBarItemType: UINavigationController] = [:]
    private var curentSelectedItemType: TabBarItemType?
    private var curentTabBarItem: UITabBarItem?
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    // MARK: Publik func
    
    func setSelectedTab() {
        embedTabBar.selectedItem = embedTabBar.items?.first
        updateSelectedViewController()
    }
    
}

// MARK: Private

fileprivate extension AppFlowController {
    
    private func initialSetup() {
        
        embedTabBar.delegate = self
        availableTabBarItemTypes.forEach({ embedViewControllers[$0] = childViewControllers(itemForVC: $0)})
        embedTabBar.tabAppearance = { [weak self] in
            self?.updateSelectedViewController()
        }
        embedTabBar.items = availableTabBarItemTypes.map { $0.item }
        embedTabBar.isTranslucent = false
        view.backgroundColor = .white
        view.addSubview(embedTabBar)
        embedTabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.view.leadingAnchor.constraint(equalTo: embedTabBar.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: embedTabBar.trailingAnchor),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: embedTabBar.bottomAnchor)
        ])
        embedTabBar.selectedItem = embedTabBar.items?.first
        updateSelectedViewController()
    }
    
    
    // MARK: Child viewControllers
    
    func childViewControllers(itemForVC: TabBarItemType) -> UINavigationController {
        
        switch itemForVC {
        case .first:
            let navigController = UINavigationController()
            var firstCoordinator: ListCoordinatorProtocol = ListCoordinator()
            firstCoordinator.navigationController = navigController
            firstCoordinator.start()
            navigController.tabBarItem = itemForVC.item
            return navigController
        case .second:
            let navigController = UINavigationController()
            var secondCoordinator: MainCoordinatorProtocol = MainCoordinator()
            secondCoordinator.navigationController = navigController
            secondCoordinator.start()
            navigController.tabBarItem = itemForVC.item
            return navigController
        }
    }
    
    func updateSelectedViewController() {
        guard let item = embedTabBar.selectedItem,
              let itemType = TabBarItemType(rawValue: item.tag) else { return }
        
        if let item: TabBarItemType = curentSelectedItemType,
           let vc: UIViewController = embedViewControllers[item] {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        if itemType == curentSelectedItemType,
           let selectedVC: UINavigationController = embedViewControllers[itemType],
           selectedVC.viewControllers.count > 1 {
            selectedVC.popViewController(animated: true)
        }
        curentSelectedItemType = itemType
        curentTabBarItem = embedTabBar.selectedItem
        if let selectedVC: UIViewController = embedViewControllers[itemType] {
            selectedVC.additionalSafeAreaInsets.bottom = embedTabBar.bounds.height
            addChild(selectedVC)
            selectedVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            selectedVC.view.frame = view.bounds
            view.addSubview(selectedVC.view)
            selectedVC.didMove(toParent: self)
        }
        view.bringSubviewToFront(embedTabBar)
    }
}

// MARK: UITabBarDelegate

extension AppFlowController: UITabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // here is the logic for selecting items
        updateSelectedViewController()
    }
}

