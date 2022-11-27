//
//  ListDetailViewController.swift
//  EfVideo
//
//  Created by user on 05.11.2022.
//

import UIKit
import AVFoundation

class ListDetailViewController: BaseViewController {

    @IBOutlet weak var containerView: UIView!
    
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
        self.title = "Film"
        self.view.backgroundColor = .black
        
        guard let videoUrl = video else { return }
        let constWidth = UIScreen.main.bounds.size.width
        player = VideoPlayer(video: videoUrl, rect: CGRect(x: 0, y: 0, width: constWidth, height: containerView.frame.height))
        
        guard let player = player else { return }
        self.player?.isUserInteractionEnabled = true
        containerView.addSubview(player)
        self.player?.handlerEvent = { [unowned self] newUrl in
            self.shareVideo(newUrl)
        }
    }
    
    func shareVideo(_ url: URL) {
//        let localVideoPath = "your_video_path_here..."
//            let videoURL = URL(fileURLWithPath: localVideoPath)

            let activityItems: [Any] = [url, "Check this out!"]
            let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

            activityController.popoverPresentationController?.sourceView = view
            activityController.popoverPresentationController?.sourceRect = view.frame

            self.present(activityController, animated: true, completion: nil)
    }
}
