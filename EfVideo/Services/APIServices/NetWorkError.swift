//
//  NetWorkError.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import Foundation

enum NetworkError: Error {
    case unknownError
    case connectionError
    case invalidCredentials
    case invalidRequest
    case notFound
    case notEmployeeId
    case notAnnualType
    case invalidResponse
    case serverError
    case serverUnavailable
    case timeOut
    case unsuppotedURL
    case noData
}
