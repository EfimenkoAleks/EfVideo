//
//  ListInterfaces.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import Foundation

protocol ListViewModelInputProtocol: AnyObject {}

protocol ListViewModelOutputProtocol: AnyObject {
    var delegate: ListViewModelDelegate? { set get }
    func models() -> [VideoModel]
}

protocol ListViewModelProtocol: ListViewModelInputProtocol, ListViewModelOutputProtocol {}

//protocol MainRouterProtocol: AnyObject {
//    func routToDetail(model: URL?)
//}

protocol ListViewModelDelegate: AnyObject {
    func didFetchingData()
}
