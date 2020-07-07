//
//  VideoPlayerController.swift
//  WebPlayer
//
//  Created by Denis Khlopin on 07.07.2020.
//

import UIKit
import StreamLayer
import StreamLayerVendor
import RxSwift
import XCDYouTubeKit
import AVKit
import SnapKit

class VideoPlayerController: UIViewController {

  var autoPlay = true
  let progressInSeconds = StreamLayerVendor.BehaviorRelay<Int>(value: 0)
  fileprivate let onTapSubject = StreamLayerVendor.PublishSubject<UITapGestureRecognizer>()
  var onTap: StreamLayerVendor.Observable<UITapGestureRecognizer>!
  private let videoPlayerViewController = AVPlayerViewController()

  private lazy var tapView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  fileprivate var statusObserver: NSKeyValueObservation?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupTapGesture()
  }

  fileprivate func setupTapGesture() {
    onTap = onTapSubject.asObservable()
    let onTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapHandler(_:)))
    onTapGesture.numberOfTapsRequired = 1
    onTapGesture.cancelsTouchesInView = false
    tapView.addGestureRecognizer(onTapGesture)
  }

  fileprivate func setupUI() {
    videoPlayerViewController.willMove(toParent: self)
    addChild(videoPlayerViewController)
    view.addSubview(videoPlayerViewController.view)
    videoPlayerViewController.didMove(toParent: self)
    videoPlayerViewController.view.frame = view.bounds
    view.addSubview(tapView)
    tapView.snp.makeConstraints {
      $0.margins.equalToSuperview()
    }
  }

  @objc private func onTapHandler(_ gesture: UITapGestureRecognizer) {
    onTapSubject.onNext(gesture)
  }

  func deactivate() {
  }

  func setNewStreamURL(withURL url: String, providerType: SLRVideoPlayerProviderType) {
    switch providerType {
    case .youtube:
      XCDYouTubeClient.default().getVideoWithIdentifier(url) { [weak self] (video, error) in
        guard let self = self else {
          return
        }
        if let error = error {
          //need to handle error here
          print(error)
          return
        }
        if let video = video {
          self.setNewUrl(video.streamURL)
        }
      }
    case .vimeo:
      // TODO: - get vimeo URL by videoID
      break
    }
  }

  fileprivate func setNewUrl(_ url: URL) {
    let asset = AVAsset(url: url)
    var error: NSError?
    asset.loadValuesAsynchronously(forKeys: ["playable"]) {
      let status = asset.statusOfValue(forKey: "playable", error: &error)
      switch status {
      case .loaded:
        DispatchQueue.main.async {
          let item = AVPlayerItem(asset: asset)
          self.videoPlayerViewController.player = AVPlayer(playerItem: item)
          self.startObserving()
          if self.autoPlay {
            self.playVideo()
          }
        }
      case .failed, .cancelled:
        break
      default:
        break
      }
    }
  }

  func playVideo() {
    if let player = self.videoPlayerViewController.player {
      player.play()
    }
  }

  func pauseVideo() {
    if let player = self.videoPlayerViewController.player {
      player.pause()
    }
  }

  private func getPlayer() -> AVPlayer? {
    return videoPlayerViewController.player
  }

}

extension VideoPlayerController {
  private func startObserving() {
    guard let player = getPlayer() else {
      return
    }
    statusObserver = player.observe(\.status) { player, _ in
      switch player.status {
      case .readyToPlay:
        break
      case .unknown, .failed:
        break
      @unknown default:
        fatalError()
      }
    }

  }
}

extension VideoPlayerController: SLROverlayDelegate {
  func requestAudioDucking() {
    print(#function)
  }

  func disableAudioDucking() {
    print(#function)
  }

  func prepareAudioSession(for type: SLRAudioSessionType) {
    print(#function, "\(type == .generic ? "generic" : "voice")")
  }

  func disableAudioSession(for type: SLRAudioSessionType) {
    print(#function, "\(type == .generic ? "generic" : "voice")")
  }

  func shareInviteMessage() -> String {
    print(#function)
    return "Share"
  }

  func waveMessage() -> String {
    print(#function)
    return "hello!"
  }

  func overlayOpened() {
    print(#function)
  }

  func overlayClosed() {
    print(#function)
  }
}
