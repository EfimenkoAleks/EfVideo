//
//  ListApiProtocol.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import Foundation

protocol ListApiProtocol {
    func getListVideo(completionHandler: @escaping (Result<ListModel, Error>) -> Void)
}
