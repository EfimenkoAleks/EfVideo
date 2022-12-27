//
//  ListDetailViewModel.swift
//  EfVideo
//
//  Created by user on 05.11.2022.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation

class ListDetailViewModel {

    private var _loading: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: true)
    
    init() {
       
    }
}

extension ListDetailViewModel: ListDetailViewModelOutputProtocol {
    
    var loading: Observable<Bool> {
        return _loading.asObservable()
    }
}

