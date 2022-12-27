//
//  PlayerHelper.swift
//  EfVideo
//
//  Created by user on 17.12.2022.
//

import UIKit
import AVFoundation
import MobileCoreServices

class PlayerHelper {
    
    init() {}
    
    func getDataFor(statTime: CMTime, endTime: CMTime, asset: AVAsset, completion: @escaping (URL?) -> ()) {
        
        let asset = asset
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
        let preferredPreset = AVAssetExportPreset1280x720
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
        
        let timeRange = CMTimeRange(start: statTime, end: endTime)
        
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
    
    func createTimeLabel() -> UILabel {
        let label = UILabel()
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 5.0
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.black
        label.textAlignment = NSTextAlignment.center
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
   
    func createTime(_ sliderValue: Float, time: CMTime) -> CMTime {
        let durationTime = CMTimeGetSeconds(time)
        
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
