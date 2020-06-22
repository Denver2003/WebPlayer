//
//  DoteLineView.swift
//  WebPlayer
//
//  Created by Denis Khlopin on 19.06.2020.
//

import UIKit

class DoteViewSeparator: UIView {
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    isOpaque = false
    backgroundColor = .clear
  }

  override init(frame: CGRect) { super.init(frame: frame) }

  override func draw(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()!
    // Bezier Drawing
    context.saveGState()
    let bezierPath = UIBezierPath()
    bezierPath.move(to: CGPoint(x: 0, y: 0))
    bezierPath.addLine(to: CGPoint(x: rect.width, y: 0))
    UIColor(red: 71, green: 72, blue: 74, alpha: 1).setStroke()
    bezierPath.lineWidth = 1
    bezierPath.lineCapStyle = .round
    bezierPath.lineJoinStyle = .round
    context.saveGState()
    context.setLineDash(phase: 0, lengths: [2, 3])
    bezierPath.stroke()
    context.restoreGState()

    context.restoreGState()
  }
}
