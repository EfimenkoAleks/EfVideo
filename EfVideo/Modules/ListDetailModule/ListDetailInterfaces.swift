//
//  ListDetailInterfaces.swift
//  EfVideo
//
//  Created by user on 05.11.2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol ListDetailViewModelInputProtocol: AnyObject {}

protocol ListDetailViewModelOutputProtocol: AnyObject {
//    var dataList: Driver<[VideoModel]> { get }
    var loading: Observable<Bool> { get }
}

protocol ListDetailViewModelProtocol: ListDetailViewModelInputProtocol, ListDetailViewModelOutputProtocol {}

protocol ListDetailViewModelDelegate: AnyObject {
  //  func didFetchingData()
}

