//
//  Coordinator.swift
//  EfVideo
//
//  Created by user on 16.10.2022.
//

import Foundation
import UIKit

protocol Coordinator {
    var navigationController: UINavigationController? { get set }
    var cildren: [Coordinator] { get set }
}

protocol Coordinating {
    var coordinator: Coordinator? { get set }
}
