//
//  VideoTableViewManager.swift
//  EfVideo
//
//  Created by user on 17.12.2022.
//

import UIKit
import Photos

enum VideoEvent {
    case reload
    case selectedVideo(VideoModel)
}

class VideoTableViewManager: NSObject {
    
    private var isLoadingList: Bool = false
    
    var tableView: UITableView
    var data: [VideoModel]
    var eventHandler: ((VideoEvent) -> Void)?
    
    init(_ tableView: UITableView, data: [VideoModel]) {
        self.tableView = tableView
        self.data = data
        super.init()
        
        registerTableViewCells()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func reloadTable(data: [VideoModel]) {
        self.data = data
        tableView.reloadData()
    }
}

extension VideoTableViewManager {
    
    func registerTableViewCells() {
        tableView.register(ListVideoCell.nib, forCellReuseIdentifier: ConstantId.listVideoCell)
    }
}

extension VideoTableViewManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConstantId.listVideoCell, for: indexPath)
                as? ListVideoCell else { return UITableViewCell() }
        
        let model = data[indexPath.row]
        
        cell.configureSecondModule(model: model)
        return cell
    }
}

extension VideoTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if eventHandler != nil {
            eventHandler?(.selectedVideo(data[indexPath.row]))
        }
    }
}
