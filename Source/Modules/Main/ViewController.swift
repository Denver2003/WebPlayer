//
//  ViewController.swift
//  WebPlayer
//
//  Created by Denis Khlopin on 19.06.2020.
//

import UIKit
import StreamLayer
import StreamLayerVendor
import RxSwift

private let overlayOffset: CGFloat = 40
private let screenRatio: CGFloat = 9/16
private let overlayViewWidth: CGFloat = 300

class ViewController: UIViewController {
  private let videoPlayer = SLRVideoPlayer()
  private let overlayView = UIView()
  private let disposeBag = StreamLayerVendor.DisposeBag()
  private let rxDisposeBag = RxSwift.DisposeBag()
  private var streamsViewController: StreamViewController?
  private lazy var overlayVC = StreamLayer.createOverlay(
    overlayView,
    overlayDelegate: videoPlayer
  )
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  fileprivate var screenWidth: CGFloat {
    let statusBarOrientation = UIApplication.shared.statusBarOrientation
    if statusBarOrientation != .portrait && statusBarOrientation != .portraitUpsideDown {
      return UIScreen.main.bounds.size.height
    } else {
      return UIScreen.main.bounds.size.width
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupInteractions()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    SLRStateMachine.onOrientationChange(disposeBag, setupConstraints(_:))
  }

  private func setupConstraints(_ orientation: OrientationState) {
    switch orientation {
    case .horizontal: horizontalOrientation()
    default: verticalOrientation()
    }
  }

  private func verticalOrientation() {
    videoPlayer.view.snp.remakeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.left.right.equalTo(0)
      $0.height.equalTo(ceil(screenWidth * (screenRatio)))
    }

    overlayView.snp.remakeConstraints {
      $0.bottom.left.right.equalToSuperview()
      $0.top.equalTo(videoPlayer.view.snp.bottom).offset(-overlayOffset)
    }

    overlayVC.view.snp.remakeConstraints {
      $0.top.equalTo(videoPlayer.view.snp.bottom).offset(-overlayOffset)
      $0.left.right.bottom.equalTo(0)
    }

    streamsViewController?.view.snp.remakeConstraints {
      $0.top.equalTo(videoPlayer.view.snp.bottom)
      $0.bottom.right.left.equalToSuperview()
    }
  }

  private func horizontalOrientation() {
    videoPlayer.view.snp.remakeConstraints {
      $0.edges.equalTo(view)
    }

    overlayView.snp.remakeConstraints { make in
      make.left.top.bottom.equalToSuperview()
      make.right.equalTo(view.safeAreaLayoutGuide.snp.left).offset(overlayViewWidth + overlayOffset)
    }

    overlayVC.view.snp.remakeConstraints { make in
      make.edges.equalTo(view)
    }

    streamsViewController?.view.snp.remakeConstraints {
      $0.top.equalTo(videoPlayer.view.snp.bottom)
      $0.bottom.right.left.equalToSuperview()
    }
  }

  func setupViews() {
    view.addSubview(overlayView)
    videoPlayer.willMove(toParent: self)
    addChild(videoPlayer)
    view.addSubview(videoPlayer.view)
    videoPlayer.didMove(toParent: self)
    setupStreamSelector()
    overlayVC.willMove(toParent: self)
    addChild(overlayVC)
    view.addSubview(overlayVC.view)
    overlayVC.didMove(toParent: self)
  }

  private func setupStreamSelector() {
    let streamViewModel = StreamViewModel()
    streamsViewController = StreamViewController(viewModel: streamViewModel)
    guard let streamsViewController = streamsViewController else { fatalError() }

    addChild(streamsViewController)
    streamsViewController.view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    streamsViewController.view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    view.addSubview(streamsViewController.view)

    streamViewModel.streamObserver.subscribe(
      onNext: { [unowned self] (stream) in
        guard let stream = stream else {
          return
        }
        self.videoPlayer.pauseVideo()
        self.videoPlayer.setNewStreamURL(withURL: stream.streamURL, providerType: .youtube)
        StreamLayer.changeStreamEvent(for: stream.eventId)
      }).disposed(by: rxDisposeBag)
  }

  private func setupInteractions() {
    videoPlayer.onTap?
      .subscribe(onNext: { [weak self] _ in
        self?.overlayVC.close()
      })
      .disposed(by: disposeBag)
    overlayVC.delegate = videoPlayer
  }
}
