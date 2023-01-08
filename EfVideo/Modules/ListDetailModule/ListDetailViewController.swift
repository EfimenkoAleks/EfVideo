//
//  ListDetailViewController.swift
//  EfVideo
//
//  Created by user on 05.11.2022.
//

import UIKit

class ListDetailViewController: BaseViewController {

    @IBOutlet private weak var containerView: UIView!
    
    var coordinator: ListDetailCoordinator?
    
    lazy var viewModel: ListDetailViewModelOutputProtocol = {
        let viewModel = ListDetailViewModel()
        return viewModel
    }()
    
    private var player: VideoPlayer?
    
    init(video: VideoModel?) {
        
        super.init()

        configureUI(video)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    deinit {
        coordinator?.handlerBback?()
    }
}

private extension ListDetailViewController {
    
    func configureUI(_ video: VideoModel?) {
        self.title = video?.title ?? ""
        self.view.backgroundColor = .black
        
        guard let videoUrl = video else { return }
        let constWidth: CGFloat = UIScreen.main.bounds.size.width
        let height: CGFloat = UIScreen.main.bounds.size.height * 0.8

        player = VideoPlayer(video: videoUrl, rect: CGRect(x: 0, y: 0, width: constWidth, height: height))
        
        guard let player = player else { return }
        self.player?.isUserInteractionEnabled = true
        containerView.addSubview(player)
        self.player?.handlerEvent = { [unowned self] newUrl in
            self.shareVideo(newUrl)
        }
    }
    
    func shareVideo(_ url: URL) {
        let activityItems: [Any] = [url]
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityController.popoverPresentationController?.sourceView = view
        activityController.popoverPresentationController?.sourceRect = view.frame
        
        self.present(activityController, animated: true, completion: nil)
    }
}
