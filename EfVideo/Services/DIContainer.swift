//
//  DIContainer.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import Foundation

struct DIContainer {

    static var `default` = Self()
    
    lazy var listService: ListApiProtocol = ListApiImpl()
}
