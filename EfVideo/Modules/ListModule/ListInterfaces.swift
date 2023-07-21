//
//  ListInterfaces.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol ListViewModelInputProtocol: AnyObject {}

protocol ListViewModelOutputProtocol: AnyObject {
    var dataList: Driver<[Videos]> { get }
    var loading: Observable<Bool> { get }
}

protocol ListViewModelProtocol: ListViewModelInputProtocol, ListViewModelOutputProtocol {}

protocol ListViewModelDelegate: AnyObject {
    func didFetchingData()
}
