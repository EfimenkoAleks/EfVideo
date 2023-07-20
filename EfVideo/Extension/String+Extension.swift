//
//  String+Extension.swift
//  EfVideo
//
//  Created by user on 19.07.2023.
//

import Foundation

extension String {
    func appendURLParams(_ params: [String: String]) -> String {
        guard !params.isEmpty else { return self }
        return URL(string: self)?.append(params: params) ?? ""
    }
}
