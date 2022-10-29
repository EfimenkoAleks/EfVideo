//
//  FechrsContainer.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import Foundation

class FechrsContainer {
    
    static let shared = FechrsContainer()
    lazy var listService: ListApiProtocol = ListApiImpl()
}
