//
//  NetworkServiceProtocol.swift
//  EfVideo
//
//  Created by user on 19.07.2023.
//

import Foundation
import RxSwift

protocol NetworkServiceProtocol {
    func getListVideo<T: Codable>(url: URL) -> Observable<T>
    func getListVideoMock(completionHandler: @escaping (Result<ListModel, Error>) -> Void)
}

