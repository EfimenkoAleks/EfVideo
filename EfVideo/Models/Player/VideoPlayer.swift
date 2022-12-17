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
    private var cutView: UIView?
    private var cutSlider: MultiSlider?
    private var sliderValue: SliderValue?
    private var label1: UILabel?
    private var label2: UILabel?
    
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
        configureUI()
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
    
    func configureUI() {
        backgroundColor = UIColor.black
        
        
        let width = (frame.width * 0.97).rounded()
        let height = (width / 16 * 9).rounded()
        heightVideoView.constant = height
        widthVideoView.constant = width
        vwPlayer.layoutIfNeeded()
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
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
        
        let currentSec = secondsToHoursMinutesSeconds(Int(sec.rounded()))
        let durationSec = secondsToHoursMinutesSeconds(Int(duration.rounded()))
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
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) { [weak self] (progressTime) in
            if self?.isScrubbingInProgress == false, self?.isAutoPlay == true, let duration = self?.player.currentItem?.duration {

                let durationSeconds = CMTimeGetSeconds(duration)
                let seconds = CMTimeGetSeconds(progressTime)
                let progress = Float(seconds/durationSeconds)

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
        
        cutView = UIView()
        cutView?.layer.cornerRadius = 10
        cutView?.layer.borderWidth = 1
        cutView?.layer.borderColor = UIColor.white.cgColor
        cutView?.layer.masksToBounds = true
        cutView?.backgroundColor = UIColor.black
        cutView?.translatesAutoresizingMaskIntoConstraints = false
        guard let cutView = cutView else { return }
        allContainerView.addSubview(cutView)
        
        NSLayoutConstraint.activate([
            cutView.bottomAnchor.constraint(equalTo: allContainerView.bottomAnchor),
            cutView.leadingAnchor.constraint(equalTo: allContainerView.leadingAnchor),
            cutView.trailingAnchor.constraint(equalTo: allContainerView.trailingAnchor),
            cutView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        let constMinValue: CGFloat = 0.0
        let constMaxValue: CGFloat = 100.0
        
        cutSlider = MultiSlider()
        cutSlider?.minimumValue = constMinValue    // default is 0.0
        cutSlider?.maximumValue = constMaxValue   // default is 1.0
        cutSlider?.outerTrackColor = .lightGray
        cutSlider?.orientation = .horizontal
        
        cutSlider?.valueLabelPosition = .notAnAttribute // .notAnAttribute = don't show labels
        cutSlider?.isValueLabelRelative = true // show differences between thumbs instead of absolute values
        cutSlider?.valueLabelFormatter.positiveSuffix = ""
        
        cutSlider?.tintColor = UIColor.systemBlue // color of track
        cutSlider?.trackWidth = 10
        cutSlider?.hasRoundTrackEnds = true
        cutSlider?.showsThumbImageShadow = false // wide tracks look better without thumb shadow
        
        cutSlider?.thumbImage   = UIImage(named: "balloon")
        cutSlider?.minimumImage = UIImage(named: "clown")
        cutSlider?.maximumImage = UIImage(named: "cloud")
        
        cutSlider?.disabledThumbIndices = []
        
        cutSlider?.snapStepSize = 0.0  // default is 0.0, i.e. don't snap

        cutSlider?.value = [constMinValue, constMaxValue]

        cutSlider?.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged) // continuous changes
        cutSlider?.addTarget(self, action: #selector(sliderDragEnded(_:)), for: . touchUpInside) // sent when drag ends
        
        cutSlider?.translatesAutoresizingMaskIntoConstraints = false
        guard let slider = cutSlider else { return }
        cutView.addSubview(slider)
        
        NSLayoutConstraint.activate([
            slider.bottomAnchor.constraint(equalTo: cutView.bottomAnchor),
            slider.leadingAnchor.constraint(equalTo: cutView.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: cutView.trailingAnchor)
        ])
        
        let sendButton = UIButton()
        sendButton.layer.borderColor = UIColor.black.cgColor
        sendButton.layer.borderWidth = 1
        sendButton.layer.cornerRadius = 5.0
        sendButton.layer.masksToBounds = true
        sendButton.backgroundColor = UIColor.systemBlue
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        cutView.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: cutView.trailingAnchor, constant: -10),
            sendButton.topAnchor.constraint(equalTo: cutView.topAnchor, constant: 8),
            sendButton.widthAnchor.constraint(equalToConstant: 80),
            sendButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        label1 = UILabel()
        label1?.layer.borderColor = UIColor.black.cgColor
        label1?.layer.borderWidth = 1
        label1?.layer.cornerRadius = 5.0
        label1?.layer.masksToBounds = true
        label1?.backgroundColor = UIColor.white
        label1?.textColor = UIColor.black
        label1?.textAlignment = NSTextAlignment.center
        label1?.text = "0"
        label1?.translatesAutoresizingMaskIntoConstraints = false
        guard let label1 = label1 else { return }
        cutView.addSubview(label1)
        
        NSLayoutConstraint.activate([
            label1.leadingAnchor.constraint(equalTo: cutView.leadingAnchor, constant: 10),
            label1.topAnchor.constraint(equalTo: cutView.topAnchor, constant: 8),
            label1.widthAnchor.constraint(equalToConstant: 100),
            label1.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        label2 = UILabel()
        label2?.layer.borderColor = UIColor.black.cgColor
        label2?.layer.borderWidth = 1
        label2?.layer.cornerRadius = 5.0
        label2?.layer.masksToBounds = true
        label2?.backgroundColor = UIColor.white
        label2?.textColor = UIColor.black
        label2?.textAlignment = NSTextAlignment.center
        label2?.text = "0"
        label2?.translatesAutoresizingMaskIntoConstraints = false
        guard let label2 = label2 else { return }
        cutView.addSubview(label2)
        
        NSLayoutConstraint.activate([
            label2.leadingAnchor.constraint(equalTo: label1.trailingAnchor, constant: 10),
            label2.topAnchor.constraint(equalTo: cutView.topAnchor, constant: 8),
            label2.widthAnchor.constraint(equalToConstant: 100),
            label2.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        sliderValue?.first = Float(constMinValue)
        sliderValue?.last = Float(constMaxValue)
    }
    
    @objc func sliderChanged(_ slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)") // e.g., [1.0, 4.5, 5.0]
        guard let first = slider.value.first, let second = slider.value.last else { return }
        
        let firstTime = createTime(Float(first)).seconds.rounded()
        let secondTime = createTime(Float(second)).seconds.rounded()
        let firstDisplayTime = secondsToHoursMinutesSeconds(Int(firstTime))
        let secondDisplayTime = secondsToHoursMinutesSeconds(Int(secondTime))
        label1?.text = firstDisplayTime
        label2?.text = secondDisplayTime
        sliderValue?.timeFirst = createTime(Float(first))
        sliderValue?.timeSecond = createTime(Float(second))
        
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
        print("now thumbs are at \(slider.value)") // e.g., [1.0, 4.5, 5.0]
        guard let first = slider.value.first, let second = slider.value.last else { return }
        
        sliderValue?.first = Float(first)
        sliderValue?.last = Float(second)
    }
    
    private func changeDableSlider(_ sliderValue: Float) {
        isSeekInProgress = true
        isAutoPlay = false
        
        let time = createTime(sliderValue)

        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let `self` = self else { return }
            self.isSeekInProgress = false
            self.isAutoPlay = true
            print("Player time after seeking: \(CMTimeGetSeconds(self.player.currentTime()))")
        }
    }
    
    private func createTime(_ sliderValue: Float) -> CMTime {
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        
        let floatTime = Float(durationTime)
        let newTime = floatTime / 100 * sliderValue
        
        return CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000)
    }

    func secondsToHoursMinutesSeconds(_ time: Int) -> String {
        let seconds = (time % 3600) % 60
        let minute = (time % 3600) / 60
        let hours = time / 3600
        var finelTime = "\(0)"
        var secondStr = ""
        var minuteStr = ""
        
        if seconds != 0 {
            secondStr = "\(seconds)"
        }
        if minute != 0 && seconds > 0 && seconds < 10 {
            secondStr = "0\(seconds)"
        }
        if minute != 0 && seconds == 0 {
            secondStr = "00"
        }
        
        if minute != 0 {
            minuteStr = "\(minute)"
        }
        if hours != 0 && minute > 0 && minute < 10 {
            minuteStr = "0\(minute)"
        }
        if hours != 0 && minute == 0 {
            minuteStr = "00"
        }
        
        if seconds != 0 {
            finelTime = "\(secondStr)"
        }
        if minute != 0 {
            finelTime = "\(minuteStr):\(secondStr)"
        }
        if hours != 0 {
            finelTime = "\(hours):\(minuteStr):\(secondStr)"
        }
        return finelTime
    }
}


struct SliderValue {
    var first: Float
    var last: Float
    var timeFirst: CMTime?
    var timeSecond: CMTime?
}
