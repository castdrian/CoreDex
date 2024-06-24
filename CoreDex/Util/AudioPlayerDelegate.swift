//
//  AudioPlayerDelegate.swift
//  CoreDex
//
//  Created by Adrian Castro on 25.02.24.
//

import AVFoundation
import Foundation

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onAudioFinished: (() -> Void)?

    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully _: Bool) {
        onAudioFinished?()
    }
}
