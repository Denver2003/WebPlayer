//
//  Stream.swift
//  WebPlayer
//
//  Created by Denis Khlopin on 19.06.2020.
//

import Foundation

struct Stream {
  var eventId: Int
  // урл к случайной картинке
  var eventImageUrlString: String = "https://picsum.photos/300/200"
  var isLive: Bool
  var titleText: String
  var subTitleText: String
  var timeText: String = "7:00 PM"
  var streamURL: String
}
