//
//  AudioPlayer.swift
//  RFIDTools
//
//  Created by zsg on 2024/5/22.
//

import AVKit
import Foundation

class AudioPlayer {
    public static let shared = AudioPlayer()

    private var audioPlayer: AVAudioPlayer?
    private let playerQueue = DispatchQueue(label: "com.RFIDTools.playerQueue")

    private init() {
        guard let audioPath = Bundle.main.path(forResource: "barcodebeep", ofType: "mp3") else {
            print("Audio file cannot be found")
            return
        }
        let audioURL = URL(fileURLWithPath: audioPath)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.enableRate = true
            audioPlayer?.rate = 3
        } catch {
            print("Audio initialization error：\(error)")
        }
    }

    func playAudio() {
//        playerQueue.async {
//            self.audioPlayer?.play()
//        }
    }

//    func stopAudio() {
//        audioPlayer?.stop()
//    }
}
