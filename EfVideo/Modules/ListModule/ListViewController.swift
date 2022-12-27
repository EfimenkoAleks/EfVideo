//
//  ListViewController.swift
//  EfVideo
//
//  Created by user on 21.10.2022.
//

import UIKit
import RxSwift
import RxCocoa

class ListViewController: BaseViewController {
    
    @IBOutlet private weak var blueView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    
    var coordinator: ListCoordinatorProtocol?
    
    private var tableViewManager: ListTableViewManager?
    private var helper: ListHelper = ListHelper()
    
    lazy var viewModel: ListViewModelOutputProtocol = {
        let viewModel = ListViewModel()
        return viewModel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
}

private extension ListViewController {
    
    func setupUI() {
        self.view.backgroundColor = .white
        helper.complexShape(inputView: blueView)
        bindUI()
    }
    
    func setupTable(_ data: [VideoModel]) {
        self.tableViewManager = ListTableViewManager(tableView, data: data)
        self.tableViewManager?.eventHandler = { [unowned self] event in
            self.showVideo(event)
        }
    }
    
    func bindUI() {
        viewModel.loading.bind(to: self.rx.isAnimating).disposed(by: disposeBag)
        viewModel.dataList.drive(onNext: {[unowned self] newValue in
            self.setupTable(newValue)
        }).disposed(by: disposeBag)
    }
    
    func showVideo(_ video: ListEvent) {
        switch video {
        case .reload:
            break
        case .selectedVideo(let video):
            coordinator?.eventOccurred(with: .detail(video))
        }
    }
}
