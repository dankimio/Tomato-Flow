import AVFoundation
import Foundation

final class SoundPlayer {

  private var player: AVAudioPlayer?

  func play(resource name: String, withExtension ext: String) {
    guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
      return
    }

    do {
      player = try AVAudioPlayer(contentsOf: url)
      player?.prepareToPlay()
      player?.play()
    } catch {
      print("Failed to play sound: \(error)")
    }
  }
}
