//
//  StreamCellViewModel.swift
//  WebPlayer
//
//  Created by Denis Khlopin on 19.06.2020.
//

import Foundation
import RxSwift

class StreamCellViewModel {
  let stream: Stream!
  var imageObserver = BehaviorSubject<Data?>(value: nil)

  init(stream: Stream) {
    self.stream = stream
    loadImage()
  }

  func loadImage() {
    if let url = URL(string: stream.eventImageUrlString) {
      URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
        if let data = data {
          self?.imageObserver.onNext(data)
        }
      }.resume()
    }
  }
}
