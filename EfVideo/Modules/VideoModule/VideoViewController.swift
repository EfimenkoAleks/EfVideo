//
//  VideoViewController.swift
//  EfVideo
//
//  Created by user on 14.10.2022.
//

import UIKit
import AVFoundation

class VideoViewController: BaseViewController {
    
    @IBOutlet private weak var playButton: ControlButton!
    @IBOutlet private weak var muteButton: ControlButton!
    @IBOutlet private weak var backPlayButton: ControlButton!
    @IBOutlet private weak var forwardPlayButton: ControlButton!
    @IBOutlet private weak var resizeButton: ControlButton!
    @IBOutlet private weak var containerVideoView: UIView!
    @IBOutlet private weak var progresView: UIProgressView!
    
    private let player: AVQueuePlayer
    private var isPlayed: Bool = true
    
    override init() {
        let url1 = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        let url2 = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")
        let url3 = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")
        let urls: [URL] = [url1!, url2!, url3!]
        
        var playerItems = [AVPlayerItem]()
        
        urls.forEach { (url) in
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            playerItems.append(playerItem)
        }
        
        player = AVQueuePlayer(items: playerItems)
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        //5. Play Video
        setPlayButton()
        observTrack()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
    }
    
    @objc private func playerEndedPlaying(_ notification: Notification) {
        DispatchQueue.main.async {[weak self] in
            self?.player.seek(to: CMTime.zero)
            self?.player.play()
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing || newStatus == .paused {
                        self?.showLoader()
                    } else {
                        self?.hideLoader()
                    }
                }
            }
        }
    }
    
    @IBAction private func tapPlayButton(_ sender: UIButton) {
        if !isPlayed {
            setPlayButton()
            isPlayed.toggle()
        } else {
            setPauseButton()
            isPlayed.toggle()
        }
    }
    
    @IBAction private func tapMuteButton(_ sender: UIButton) {
        if player.isMuted {
            setMute()
        } else {
            setUnMute()
        }
    }
    
    @IBAction private func tapBackButton(_ sender: UIButton) {
        rewindVideo(by: 15)
    }
    
    @IBAction private func tapForwardButton(_ sender: UIButton) {
        forwardVideo(by: 15)
    }
    
    @IBAction private func tapResizeButton(_ sender: UIButton) {
    }
}

private extension VideoViewController {
    
    func configureUI() {
        self.title = "Main"
        self.view.backgroundColor = .black
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.containerVideoView.bounds
        playerLayer.videoGravity = .resize
        
        self.containerVideoView.layer.addSublayer(playerLayer)
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
        playButton.setImage(image, for: .normal)
        player.play()
    }
    
    func setPauseButton() {
        let image = UIImage(systemName: "play.fill")
        playButton.setImage(image, for: .normal)
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
                    self?.progresView.progress = progress
                    if progress >= 1.0 {
                        self?.progresView.progress = 0.0
                    }
                }
            }
        }
    }
}
