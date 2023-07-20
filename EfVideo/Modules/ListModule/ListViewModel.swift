//
//  ListViewModel.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation

class ListViewModel {
    
    private var _fetcher: FecherListVideo
    private var _dataList: BehaviorSubject<[Videos]> = BehaviorSubject<[Videos]>(value: [])
    private var _loading: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: true)
    private var disposeBag: DisposeBag = DisposeBag()
    private let page: Int = 1
    
    init(fetcher: FecherListVideo = DIContainer.default.listService) {
        self._fetcher = fetcher
        
        fechData()
    }
    
    private func fechData() {
        
        _fetcher.getVideoList(page: page).map { videos -> [Videos] in
            self._loading.onNext(false)
            return videos.videos
        }
        .bind(to: _dataList)
        .disposed(by: disposeBag)
    }
    
//    private func fechData() {
//        // Simulating a download from a server
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
//            self._loading.onNext(false)
//            _fetcher.getListVideo { result in
//                switch result {
//                case .success(let model):
//                    let albums = model.categories.first?.videos ?? []
//                    self._dataList.onNext(albums)
//                case .failure(let error):
//                    self._dataList.onNext([])
//                    print(error.localizedDescription)
//                }
//            }
//        }
//    }
}

extension ListViewModel: ListViewModelOutputProtocol {
    var dataList: Driver<[Videos]> {
        return _dataList.asDriver(onErrorJustReturn: [])
    }
    
    var loading: Observable<Bool> {
        return _loading.asObservable()
    }
}
