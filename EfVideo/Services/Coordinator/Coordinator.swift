//
//  Coordinator.swift
//  EfVideo
//
//  Created by user on 16.10.2022.
//

import Foundation
import UIKit

enum Event {
    case buttonTapped
}

protocol Coordinator {
    var navigationController: UINavigationController? { get set }
    var cildren: [Coordinator]? { get set }
    
    func eventOccurred(with type: Event)
    func start()
}

protocol Coordinating {
    var coordinator: Coordinator? { get set }
}
