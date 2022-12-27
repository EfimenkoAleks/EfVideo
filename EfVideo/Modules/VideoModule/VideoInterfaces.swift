//
//  VideoInterfaces.swift
//  EfVideo
//
//  Created by user on 17.12.2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol VideoViewModelInputProtocol: AnyObject {}

protocol VideoViewModelOutputProtocol: AnyObject {
    var dataList: Driver<[VideoModel]> { get }
    var loading: Observable<Bool> { get }
}

protocol VideoViewModelProtocol: VideoViewModelInputProtocol, VideoViewModelOutputProtocol {}

protocol VideoViewModelDelegate: AnyObject {
    func didFetchingData()
}
