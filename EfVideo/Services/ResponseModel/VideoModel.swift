//
//  VideoModel.swift
//  EfVideo
//
//  Created by user on 18.07.2023.
//

import Foundation

struct Videos: Codable {
    var id: Int
    var width: Int
    var height: Int
    var url: String
    var image: String
    var videoFiles: [VideoFile]
    var videoPictures: [VideoPicture]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case url
        case image
        case videoFiles = "video_files"
        case videoPictures = "video_pictures"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(url, forKey: .url)
        try container.encode(image, forKey: .image)
        try container.encode(videoFiles, forKey: .videoFiles)
        try container.encode(videoPictures, forKey: .videoPictures)
      }
    
      init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
          id = try container.decode(Int.self, forKey: .id)
          width = try container.decode(Int.self, forKey: .width)
          height = try container.decode(Int.self, forKey: .height)
          url = try container.decode(String.self, forKey: .url)
          image = try container.decode(String.self, forKey: .image)
          videoFiles = try container.decode([VideoFile].self, forKey: .videoFiles)
          videoPictures = try container.decode([VideoPicture].self, forKey: .videoPictures)
      }
}

struct VideoFile: Codable {
    var id: Int
    var quality: String
    var width: Int
    var height: Int
    var link: String
}

struct VideoPicture: Codable {
    var id: Int
    var picture: String
}

struct VideoPexels: Codable {
    var page: Int
    var perPage: Int
    var url: String
    var videos: [Videos]
    
    private enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case url
        case videos
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(page, forKey: .page)
        try container.encode(url, forKey: .url)
        try container.encode(videos, forKey: .videos)
        try container.encode(perPage, forKey: .perPage)
      }
    
      init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
          page = try container.decode(Int.self, forKey: .page)
          url = try container.decode(String.self, forKey: .url)
          videos = try container.decode([Videos].self, forKey: .videos)
          perPage = try container.decode(Int.self, forKey: .perPage)
      }
}
