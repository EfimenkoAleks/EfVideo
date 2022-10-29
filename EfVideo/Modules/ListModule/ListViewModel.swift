//
//  ListViewModel.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import Foundation

class ListViewModel {
    
    weak var delegate: ListViewModelDelegate?
    private var fetcher: ListApiProtocol
    private var data: [VideoModel] = []
    
    init(fetcher: ListApiProtocol) {
        self.fetcher = fetcher
        
        fechData()
    }
    
    private func fechData() {
        fetcher.getListVideo { [weak self] result in
            switch result {
                case .success(let model):
                self?.data = model.categories.first?.videos ?? []
                self?.delegate?.didFetchingData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
}

extension ListViewModel: ListViewModelProtocol {
    
    func models() -> [VideoModel] {
        return data
    }
}
