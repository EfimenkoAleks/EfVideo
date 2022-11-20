//
//  VideoPlayer.swift
//  EfVideo
//
//  Created by user on 15.11.2022.
//

import UIKit
import AVFoundation

class VideoPlayer: UIView {
    
    @IBOutlet weak var vwPlayer: UIView!
    
    @IBOutlet weak var playButton: ControlButton!
    @IBOutlet weak var muteButton: ControlButton!
    @IBOutlet weak var backButton: ControlButton!
    @IBOutlet weak var forwardButton: ControlButton!
    @IBOutlet weak var resizeButton: ControlButton!
    @IBOutlet weak var containerSliderView: UIView!
    
    private var progressBarHighlightedObserver: NSKeyValueObservation?
    private var isScrubbingInProgress: Bool = false
    private var isSeekInProgress = false
    private var isPlayed = true
    private var isAutoPlay = true
    private let player: AVPlayer
    private let playerItem: AVPlayerItem
    private let asset: AVAsset
    
    private lazy var slider: UISlider = {
        let bar = UISlider()
        bar.minimumTrackTintColor = .red
        bar.maximumTrackTintColor = .white
        bar.value = 0.0
        bar.isContinuous = false
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.addTarget(self, action: #selector(handleSliderChange(_:)), for: .valueChanged)
        self.progressBarHighlightedObserver = bar.observe(\UISlider.isTracking, options: [.old, .new]) { [weak self] (_, change) in
            if let newValue = change.newValue {
                self?.didChangeProgressBarDragging(newValue, sliderValue: bar.value)
            }
        }
        return bar
    }()

    init(video: VideoModel, rect: CGRect) {
        let videoUrl = video.sources?.first ?? ""
        let url = URL(string: videoUrl)

        asset = AVAsset(url: url!)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        super.init(frame: rect)
        
        commonInit()
        configureUI()
        setPlayButton()
        observTrack()
    }
    
    fileprivate func commonInit() {
        let viewFromXib = Bundle.main.loadNibNamed("VideoPlayer", owner: self, options: nil)?.first as! UIView
        viewFromXib.isUserInteractionEnabled = true
        viewFromXib.frame = self.bounds
            addSubview(viewFromXib)
        }
       
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playVideo() {
        setPlayButton()
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

private extension VideoPlayer {
    
    func configureUI() {
        backgroundColor = UIColor.black
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.vwPlayer.bounds
        playerLayer.videoGravity = .resize
        
        self.vwPlayer.layer.addSublayer(playerLayer)
        
        containerSliderView.addSubview(slider)
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: containerSliderView.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: containerSliderView.trailingAnchor),
            slider.centerYAnchor.constraint(equalTo: containerSliderView.centerYAnchor)
        ])
    }
    
    @objc func handleSliderChange(_ sender: UISlider) {
        isSeekInProgress = true
        isAutoPlay = false
        
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        
        let floatTime = Float(durationTime)
        let newTime = floatTime / 100 * (sender.value * 100)

        player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let `self` = self else { return }
            self.isSeekInProgress = false
            self.isAutoPlay = true
            print("Player time after seeking: \(CMTimeGetSeconds(self.player.currentTime()))")
        }
    }

    func didChangeProgressBarDragging(_ newValue: Bool, sliderValue: Float) {
        isScrubbingInProgress = newValue
        if !isScrubbingInProgress && !isSeekInProgress {
            changeSliderValue(sliderValue)
        }
    }
    func changeSliderValue(_ sliderValue: Float) {
        slider.value = sliderValue
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
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) { [weak self] (progressTime) in
            if self?.isScrubbingInProgress == false, self?.isAutoPlay == true, let duration = self?.player.currentItem?.duration {

                let durationSeconds = CMTimeGetSeconds(duration)
                let seconds = CMTimeGetSeconds(progressTime)
                let progress = Float(seconds/durationSeconds)

                DispatchQueue.main.async {
                    self?.changeSliderValue(progress)
                    if progress >= 1.0 {
                        self?.changeSliderValue(0.0)
                    }
                }
            }
        }
    }
}
