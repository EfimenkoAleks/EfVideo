//
//  VideoViewController.swift
//  EfVideo
//
//  Created by user on 14.10.2022.
//

import UIKit
import Photos

class VideoViewController: BaseViewController {
    
    
    @IBOutlet private weak var blueView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    
    var coordinator: MainCoordinatorProtocol?
    
    private var tableViewManager: VideoTableViewManager?
    private var helper: ListHelper = ListHelper()
    var videoController = UIImagePickerController()
    
    lazy var viewModel: VideoViewModelOutputProtocol = {
        let viewModel = VideoViewModel()
        return viewModel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Request access to PhotosApp
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            
            // Handle restricted or denied state
            if status == .restricted || status == .denied
            {
                print("Status: Restricted or Denied")
            }
            
            // Handle limited state
            if status == .limited
            {
                DispatchQueue.main.async {
                    self?.bindUI()
                }
                print("Status: Limited")
            }
            
            // Handle authorized state
            if status == .authorized
            {
                DispatchQueue.main.async {
                    self?.bindUI()
                }
                print("Status: Full access")
            }
        }
    }
}

private extension VideoViewController {
    
    func setupUI() {
        self.view.backgroundColor = .white
        helper.complexShape(inputView: blueView)
    }
    
    func setupTable(_ data: [VideoModel]) {
        self.tableViewManager = VideoTableViewManager(tableView, data: data)
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
    
    func showVideo(_ video: VideoEvent) {
        switch video {
        case .reload:
            break
        case .selectedVideo(let video):
            coordinator?.eventOccurred(with: .detail(video))
        }
    }
}

extension VideoViewController: UIImagePickerControllerDelegate {
    
    func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    }
}
