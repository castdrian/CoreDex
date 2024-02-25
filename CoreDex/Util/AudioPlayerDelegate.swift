//
//  AudioPlayerDelegate.swift
//  CoreDex
//
//  Created by Adrian Castro on 25.02.24.
//

import Foundation
import AVFoundation

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onAudioFinished: (() -> Void)?

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onAudioFinished?()
    }
}
