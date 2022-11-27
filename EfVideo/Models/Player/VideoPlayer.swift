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
    private var cutSlider: MultiSlider?
    
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
        
        addCutView()
        
//        getDataFor(statTime: Float(200), endTime: Float(250)) { [unowned self] newUrl in
//            guard let videoUrl = newUrl else { return }
//            DispatchQueue.main.async {
//                self.handlerEvent?(videoUrl)
//            }
//        }
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
    
    func getDataFor(statTime: Float, endTime: Float, completion: @escaping (URL?) -> ()) {
        
        let asset = self.asset
        guard asset.isExportable,
              let sourceVideoTrack = asset.tracks(withMediaType: .video).first,
              let sourceAudioTrack = asset.tracks(withMediaType: .audio).first else {
                  completion(nil)
                  return
              }
        
        let composition = AVMutableComposition()
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
                
        do {
            try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: sourceVideoTrack, at: .zero)
            try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: sourceAudioTrack, at: .zero)
        } catch {
            completion(nil)
            return
        }
        
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: composition)
        var preset = AVAssetExportPresetPassthrough
        let preferredPreset = AVAssetExportPreset1920x1080
        if compatiblePresets.contains(preferredPreset) {
            preset = preferredPreset
        }
        
        let fileType: AVFileType = .mp4

        guard let exportSession = AVAssetExportSession(asset: composition, presetName: preset),
              exportSession.supportedFileTypes.contains(fileType) else {
                  completion(nil)
                  return
              }
        
        let tempFileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp_video_data")
        
        exportSession.outputURL = tempFileUrl
        exportSession.outputFileType = fileType
    //    let startTime = CMTimeMake(value: 0, timescale: 1)
    //    let timeRange = CMTimeRangeMake(start: startTime, duration: asset.duration)
        let timeRange = CMTimeRange(start: CMTime(seconds: Double(statTime), preferredTimescale: 1000),
                                    end: CMTime(seconds: Double(endTime), preferredTimescale: 1000))
        
        exportSession.timeRange = timeRange
        
        exportSession.exportAsynchronously {
            print(tempFileUrl)
            print(String(describing: exportSession.error))
            let data = try? Data(contentsOf: tempFileUrl)
            try? FileManager.default.removeItem(at: tempFileUrl)
            let url = data?.convertToURL()
            completion(url)
        }
    }
}

private extension VideoPlayer {
    func addCutView() {
        let cutView = UIView()
        cutView.backgroundColor = .yellow
        cutView.translatesAutoresizingMaskIntoConstraints = false
        containerCutSliderView.addSubview(cutView)
        
        NSLayoutConstraint.activate([
            cutView.topAnchor.constraint(equalTo: containerCutSliderView.topAnchor, constant: -5),
            cutView.leadingAnchor.constraint(equalTo: containerCutSliderView.leadingAnchor),
            cutView.trailingAnchor.constraint(equalTo: containerCutSliderView.trailingAnchor),
            cutView.bottomAnchor.constraint(equalTo: containerCutSliderView.bottomAnchor)
        ])
        
        cutSlider = MultiSlider()
        cutSlider?.minimumValue = 1    // default is 0.0
        cutSlider?.maximumValue = 10    // default is 1.0
        cutSlider?.outerTrackColor = .lightGray
        cutSlider?.orientation = .horizontal
        
        cutSlider?.valueLabelPosition = .left // .notAnAttribute = don't show labels
        cutSlider?.isValueLabelRelative = true // show differences between thumbs instead of absolute values
        cutSlider?.valueLabelFormatter.positiveSuffix = " ?s"
        
        cutSlider?.tintColor = .cyan // color of track
        cutSlider?.trackWidth = 32
        cutSlider?.hasRoundTrackEnds = true
        cutSlider?.showsThumbImageShadow = false // wide tracks look better without thumb shadow
        
        cutSlider?.thumbImage   = UIImage(named: "balloon")
        cutSlider?.minimumImage = UIImage(named: "clown")
        cutSlider?.maximumImage = UIImage(named: "cloud")
        
        cutSlider?.disabledThumbIndices = [3, 7]
        
        cutSlider?.snapStepSize = 0.1  // default is 0.0, i.e. don't snap

        cutSlider?.value = [0, 10]

        cutSlider?.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged) // continuous changes
        cutSlider?.addTarget(self, action: #selector(sliderDragEnded(_:)), for: . touchUpInside) // sent when drag ends
        
        cutSlider?.translatesAutoresizingMaskIntoConstraints = false
        guard let slider = cutSlider else { return }
        cutView.addSubview(slider)
        
        NSLayoutConstraint.activate([
            slider.centerYAnchor.constraint(equalTo: cutView.centerYAnchor),
            slider.leadingAnchor.constraint(equalTo: cutView.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: cutView.trailingAnchor)
        ])
    }
    
    @objc func sliderChanged(_ slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)") // e.g., [1.0, 4.5, 5.0]
    }
    
    @objc func sliderDragEnded(_ slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)") // e.g., [1.0, 4.5, 5.0]
    }
}
