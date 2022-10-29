//
//  ListModel.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import Foundation

struct ListModel: Codable {
    var categories: [ListObj]
}

struct ListObj: Codable {
    var name: String
    var videos: [VideoModel]
}

struct VideoModel: Codable {
    var description: String?
    var sources: [String]?
    var subtitle: String?
    var thumb: String?
    var title: String?
}
