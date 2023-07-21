//
//  FecherListVideo.swift
//  EfVideo
//
//  Created by user on 19.07.2023.
//

import Foundation
import RxSwift

class FecherListVideo {
 
    private var baseUrlStr: String = "https://api.pexels.com/videos/popular"
    private var networkService: NetworkServiceProtocol = NetworkService()
    
    func getVideoList(page: Int) -> Observable<VideoPexels> {
        let params: [String:String] = ["page": String(page)]
        let urlStr = baseUrlStr.appendURLParams(params)
        
        return networkService.getListVideo(url: URL(string: urlStr)!)
    }
}
