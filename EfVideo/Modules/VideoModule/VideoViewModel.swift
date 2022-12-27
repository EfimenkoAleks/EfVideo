//
//  VideoViewModel.swift
//  EfVideo
//
//  Created by user on 17.12.2022.
//

import RxSwift
import RxCocoa
import UIKit
import Photos

class VideoViewModel {
    
    private var _dataList: BehaviorSubject<[VideoModel]> = BehaviorSubject<[VideoModel]>(value: [])
    private var _loading: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: true)
    
    private var videos: [VideoModel] = []
    
    let group = DispatchGroup()
    let queueVideo = DispatchQueue(label: "com.video")
    
    init() {
        
        fechData()
    }
    
    private func fechData() {
  
        let fetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: nil)
        self._loading.onNext(false)
        fetchResults.enumerateObjects({ [weak self] (object, count, stop) in
            let date = self?.convertDateToString(object.creationDate)
            self?.group.enter()
            self?.queueVideo.async(group: self?.group) {
                
                let fileName: String = object.value(forKey: "filename") as! String
                print("\(fileName)")
                
                let documentsFolder = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let videoURL = documentsFolder.appendingPathComponent(fileName)
                print("\(videoURL.path)")
                
                object.getURL { responseURL in
                    if let url = responseURL {
                        let strUrl = url.absoluteString
                        print("\(strUrl)")
                        let model = VideoModel(description: "", sources: [strUrl], subtitle: "", thumb: "", title: date)
                        
                        self?.videos.append(model)
                        self?.group.leave()
                    }
                }
            }
        })
        
        group.notify(queue: .main) { [unowned self] in
            print("all finished.")
            self._loading.onNext(false)
            self._dataList.onNext(self.videos)
        }
    }

    private func convertDateToString(_ date: Date?) -> String {
        guard let date = date else { return ""}
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let myString = formatter.string(from: date)

        return myString
    }
}

extension VideoViewModel: VideoViewModelOutputProtocol {
    var dataList: Driver<[VideoModel]> {
        return _dataList.asDriver(onErrorJustReturn: [])
    }
    
    var loading: Observable<Bool> {
        return _loading.asObservable()
    }
}
