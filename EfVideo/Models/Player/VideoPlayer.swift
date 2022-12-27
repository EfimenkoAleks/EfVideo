//
//  VideoPlayer.swift
//  EfVideo
//
//  Created by user on 15.11.2022.
//

import UIKit
import AVFoundation
import MobileCoreServices
import MultiSlider

class VideoPlayer: UIView {
 
    @IBOutlet weak var vwPlayer: UIView!
    @IBOutlet weak var playButton: ControlButton!
    @IBOutlet weak var muteButton: ControlButton!
    @IBOutlet weak var backButton: ControlButton!
    @IBOutlet weak var forwardButton: ControlButton!
    @IBOutlet weak var resizeButton: ControlButton!
    @IBOutlet weak var containerSliderView: UIView!
    @IBOutlet weak var containerCutSliderView: UIView!
    @IBOutlet weak var allContainerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var widthVideoView: NSLayoutConstraint!
    @IBOutlet weak var heightVideoView: NSLayoutConstraint!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    var handlerEvent: ((URL) -> Void)?
    
    private var progressBarHighlightedObserver: NSKeyValueObservation?
    private var isScrubbingInProgress: Bool = false
    private var isSeekInProgress = false
    private var isPlayed = true
    private var isAutoPlay = true
    private var player: AVPlayer
    private var playerItem: AVPlayerItem
    private var asset: AVAsset
    private var videoUrl: URL
    private var cutView: CutView?
    private var sliderValue: SliderValue?
    private let helper: PlayerHelper = PlayerHelper()
    
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
        self.videoUrl = url!

        asset = AVAsset(url: url!)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        super.init(frame: rect)
        
        commonInit()
        configureUI(url: url, constantHeight: rect.height)
        setPlayButton()
        observTrack()
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
    
    @IBAction func didTapCropButton(_ sender: UIButton) {
        if cutView == nil {
            sliderValue = SliderValue(first: 0.0, last: 0.0)
            addCutView()
        } else {
            cutView?.removeFromSuperview()
            cutView = nil
        }
    }
}

private extension VideoPlayer {
    
    func commonInit() {
        let viewFromXib = Bundle.main.loadNibNamed("VideoPlayer", owner: self, options: nil)?.first as! UIView
        viewFromXib.isUserInteractionEnabled = true
        viewFromXib.frame = self.bounds
            addSubview(viewFromXib)
        }
    
    func configureUI(url: URL?, constantHeight: CGFloat) {
        backgroundColor = UIColor.black
        containerHeight.constant = constantHeight
        
        guard let track = AVURLAsset(url: url!).tracks(withMediaType: AVMediaType.video).first else { return }
        let size = track.naturalSize.applying(track.preferredTransform)
        let sizeWidth = abs(size.width)
        let sizeHeight = abs(size.height)
        let constContainer: CGFloat = constantHeight - 290.0
        var heightView: CGFloat = 0.0
        var widthView: CGFloat = 0.0
        
        if sizeHeight > sizeWidth {
            heightView = constContainer
            widthView = (heightView * sizeWidth / sizeHeight).rounded()
        } else if sizeHeight < sizeWidth {
            widthView = frame.width
            heightView = (sizeHeight * widthView / sizeWidth).rounded()
        } else {
            heightView = 200
            widthView = 200
        }
        
        heightVideoView.constant = heightView
        widthVideoView.constant = widthView
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: widthView, height: heightView)
        playerLayer.videoGravity = .resize
        
        vwPlayer.layer.addSublayer(playerLayer)
        
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
    
    func setDisplayTimeVideo(seconds: Float64?, allDuration: Float64?) {
        guard let sec = seconds, let duration = allDuration else { return }
        
        let currentSec = helper.secondsToHoursMinutesSeconds(Int(sec.rounded()))
        let durationSec = helper.secondsToHoursMinutesSeconds(Int(duration.rounded()))
        timeLabel.text = "\(currentSec) / \(durationSec)"
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
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.global()) { [weak self] (progressTime) in
            if self?.isScrubbingInProgress == false, self?.isAutoPlay == true, let duration = self?.player.currentItem?.asset.duration {

                let durationSeconds: Double = Double(CMTimeGetSeconds(duration))
                let seconds: Double = progressTime.seconds
                let progress: Float = Float(seconds/durationSeconds)

                DispatchQueue.main.async {
                    self?.setDisplayTimeVideo(seconds: seconds, allDuration: durationSeconds)
                    self?.changeSliderValue(progress)
                    if progress >= 1.0 {
                        self?.changeSliderValue(0.0)
                    }
                }
            }
        }
    }
    
    @objc func didTapSendButton(sender: UIButton!) {
        guard let time1 = sliderValue?.timeFirst, let time2 = sliderValue?.timeSecond else { return }
        helper.getDataFor(statTime: time1, endTime: time2, asset: asset) { [unowned self] newUrl in
            guard let videoUrl = newUrl else { return }
            DispatchQueue.main.async {
                self.handlerEvent?(videoUrl)
            }
        }
    }
}

private extension VideoPlayer {
    func addCutView() {
        guard player.currentItem != nil else { return }
        
        cutView = CutView()
        cutView?.translatesAutoresizingMaskIntoConstraints = false
        guard let cutView = cutView else { return }
        allContainerView.addSubview(cutView)
        
        NSLayoutConstraint.activate([
            cutView.bottomAnchor.constraint(equalTo: allContainerView.bottomAnchor, constant: -20),
            cutView.leadingAnchor.constraint(equalTo: allContainerView.leadingAnchor),
            cutView.trailingAnchor.constraint(equalTo: allContainerView.trailingAnchor),
            cutView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        let constMinValue: CGFloat = 0.0
        let constMaxValue: CGFloat = 100.0
        
        sliderValue?.first = Float(constMinValue)
        sliderValue?.last = Float(constMaxValue)
        cutView.sendButton?.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        cutView.cutSlider?.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        cutView.cutSlider?.addTarget(self, action: #selector(sliderDragEnded(_:)), for: . touchUpInside)
    }
    
    @objc func sliderChanged(_ slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)") // e.g., [1.0, 4.5, 5.0]
        guard let first = slider.value.first, let second = slider.value.last else { return }
        
        let firstTime = helper.createTime(Float(first), time: asset.duration).seconds.rounded()
        let secondTime = helper.createTime(Float(second), time: asset.duration).seconds.rounded()
        let firstDisplayTime = helper.secondsToHoursMinutesSeconds(Int(firstTime))
        let secondDisplayTime = helper.secondsToHoursMinutesSeconds(Int(secondTime))
        cutView?.setLabel1(firstDisplayTime)
        cutView?.setLabel2(secondDisplayTime)
        sliderValue?.timeFirst = helper.createTime(Float(first), time: asset.duration)
        sliderValue?.timeSecond = helper.createTime(Float(second), time: asset.duration)
        
        if sliderValue?.first != Float(first) {
            sliderValue?.first = Float(first)
            changeDableSlider(sliderValue?.first ?? 0)
        } else if sliderValue?.last != Float(second) {
            sliderValue?.last = Float(second)
            changeDableSlider(sliderValue?.last ?? 0)
        }
    }
    
    @objc func sliderDragEnded(_ slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        guard let first = slider.value.first, let second = slider.value.last else { return }
        
        sliderValue?.first = Float(first)
        sliderValue?.last = Float(second)
    }
    
    private func changeDableSlider(_ sliderValue: Float) {
        isSeekInProgress = true
        isAutoPlay = false
        
        let time = helper.createTime(sliderValue, time: asset.duration)

        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let `self` = self else { return }
            self.isSeekInProgress = false
            self.isAutoPlay = true
            print("Player time after seeking: \(CMTimeGetSeconds(self.player.currentTime()))")
        }
    }
}
