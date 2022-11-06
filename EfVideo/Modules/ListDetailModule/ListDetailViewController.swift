//
//  ListDetailViewController.swift
//  EfVideo
//
//  Created by user on 05.11.2022.
//

import UIKit
import AVFoundation

class ListDetailViewController: BaseViewController {

    @IBOutlet weak var startButton: ControlButton!
    @IBOutlet weak var muteButton: ControlButton!
    @IBOutlet weak var backButton: ControlButton!
    @IBOutlet weak var forwardButton: ControlButton!
    @IBOutlet weak var resizeButton: ControlButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var filmView: UIView!
    
    var coordinator: ListDetailCoordinator?
    
    lazy var viewModel: ListDetailViewModelOutputProtocol = {
        let viewModel = ListDetailViewModel()
        return viewModel
    }()
    
    private let player: AVPlayer
    private var isPlayed: Bool = true
    
    init(video: VideoModel?) {
        let videoUrl = video?.sources?.first ?? ""
        let url = URL(string: videoUrl)

        let asset = AVAsset(url: url!)
        let playerItem = AVPlayerItem(asset: asset)

        player = AVPlayer(playerItem: playerItem)
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        // Play Video
        setPlayButton()
        observTrack()
    }
    
    deinit {
        coordinator?.handlerBback?()
    }

    @IBAction func didTapPlayButton(_ sender: UIButton) {
        if !isPlayed {
            setPlayButton()
            isPlayed.toggle()
        } else {
            setPauseButton()
            isPlayed.toggle()
        }
    }
    
    @IBAction func didTapMuteButton(_ sender: UIButton) {
        if player.isMuted {
            setMute()
        } else {
            setUnMute()
        }
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        rewindVideo(by: 15)
    }
    
    @IBAction func didTapForwardBbutton(_ sender: UIButton) {
        forwardVideo(by: 15)
    }
    
    @IBAction func didTapResizeButton(_ sender: UIButton) {
    }
    
}


private extension ListDetailViewController {
    
    func configureUI() {
        self.title = "Main"
        self.view.backgroundColor = .black
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.filmView.bounds
        playerLayer.videoGravity = .resize
        
        self.filmView.layer.addSublayer(playerLayer)
    }
    
    func setUnMute() {
        let image = UIImage(systemName: "speaker.fill")
        muteButton.setImage(image, for: .normal)
        player.isMuted = true
    }
    
    func setMute() {
        let image = UIImage(systemName: "speaker.slash.fill")
        muteButton.setImage(image, for: .normal)
        player.isMuted = false
    }
    
    func setPlayButton() {
        let image = UIImage(systemName: "pause.fill")
        startButton.setImage(image, for: .normal)
        player.play()
    }
    
    func setPauseButton() {
        let image = UIImage(systemName: "play.fill")
        startButton.setImage(image, for: .normal)
        player.pause()
    }
    
    func rewindVideo(by seconds: Float64) {
        let currentTime = player.currentTime()
        var newTime = CMTimeGetSeconds(currentTime) - seconds
        if newTime <= 0 {
            newTime = 0
        }
        player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        
    }
    
    func forwardVideo(by seconds: Float64) {
        if let duration = player.currentItem?.duration {
            let currentTime = player.currentTime()
            var newTime = CMTimeGetSeconds(currentTime) + seconds
            if newTime >= CMTimeGetSeconds(duration) {
                newTime = CMTimeGetSeconds(duration)
            }
            player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
    
    func observTrack() {
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) {[weak self] (progressTime) in
            if let duration = self?.player.currentItem?.duration {
                
                let durationSeconds = CMTimeGetSeconds(duration)
                let seconds = CMTimeGetSeconds(progressTime)
                let progress = Float(seconds/durationSeconds)
                
                DispatchQueue.main.async {
                    self?.progressView.progress = progress
                    if progress >= 1.0 {
                        self?.progressView.progress = 0.0
                    }
                }
            }
        }
    }
}

