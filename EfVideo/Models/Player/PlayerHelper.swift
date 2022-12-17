//
//  PlayerHelper.swift
//  EfVideo
//
//  Created by user on 17.12.2022.
//

import UIKit
import AVFoundation
import MobileCoreServices
import MultiSlider

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
}
