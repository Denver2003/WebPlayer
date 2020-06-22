//
//  StreamViewModel.swift
//  WebPlayer
//
//  Created by Denis Khlopin on 19.06.2020.
//

import StreamLayer
import RxSwift

class StreamViewModel {
  var streams = [Stream]() {
    didSet {
      streamsObserver.onNext(streams)
      if let first = streams.first {
        currentStream = first
      }
    }
  }
  var currentStream: Stream? {
    didSet {
      streamObserver.onNext(currentStream)
    }
  }

  // observers
  var streamObserver = BehaviorSubject<Stream?>(value: nil)
  var streamsObserver = BehaviorSubject<[Stream]>(value: [])

  init() {
    // generate streams
    generate()
  }

  func getStream(by indexPath: IndexPath) -> Stream? {
    if indexPath.row < streams.count {
      return streams[indexPath.row]
    }
    return nil
  }

  func selectStream(by indexPath: IndexPath) {
    if indexPath.row < streams.count {
      self.currentStream = streams[indexPath.row]
    }
  }

  // stream data generator
  private func generate() {
    var streams = [Stream]()
    streams.append(
      Stream(eventId: 1, isLive: true, titleText: "Stream 1", subTitleText: "Cool Stream",
             streamURL: "KvRVky0r7YM"))
    streams.append(
      Stream(eventId: 2, isLive: true, titleText: "Stream 2", subTitleText: "Cool Stream",
             streamURL: "8kHpMCDCbUA"))
    streams.append(
      Stream(eventId: 3, isLive: true, titleText: "Stream 3", subTitleText: "Cool Stream",
             streamURL: "4VIy9lF_EHg"))
    streams.append(
      Stream(eventId: 4, isLive: true, titleText: "Stream 4", subTitleText: "Cool Stream",
             streamURL: "-5KAN9_CzSA"))
    streams.append(
      Stream(eventId: 1, isLive: true, titleText: "Stream 5", subTitleText: "Cool Stream",
             streamURL: "5qky3L2Q6G4"))
    self.streams = streams
  }
}
