//
//  StreamCell.swift
//  WebPlayer
//
//  Created by Denis Khlopin on 19.06.2020.
//

import UIKit
import RxSwift
import SnapKit

private let titleFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
private let subTitleFont = UIFont.systemFont(ofSize: 14, weight: .thin)
private let generalOffset: CGFloat = 16
private let dotLineHeight: CGFloat = 1
private let topTitleOffset: CGFloat = 19
private let verticalOffset: CGFloat = 4

class StreamCell: UITableViewCell {
  var viewModel: StreamCellViewModel? {
    didSet {
      updateUI()
    }
  }
  private var disposeBag = DisposeBag()
  // ui elements
  // container
  lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()
  // preview image
  lazy var thumbImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 12
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.snp.makeConstraints {
      $0.width.equalTo(141)
    }
    return imageView
  }()

  lazy var activityImageLoad: UIActivityIndicatorView = {
    let activity = UIActivityIndicatorView()
    activity.style = .whiteLarge
    activity.hidesWhenStopped = true
    activity.startAnimating()
    return activity
  }()

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = titleFont
    label.textColor = .white
    return label
  }()

  lazy var subTitleLabel: UILabel = {
    let label = UILabel()
    label.font = subTitleFont
    label.textColor = .white
    return label
  }()

  lazy var timeLabel: UILabel = {
    let label = UILabel()
    label.font = subTitleFont
    label.textColor = .white
    return label
  }()

  let doteView = DoteViewSeparator(frame: .zero)

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  func configure() {
    backgroundColor = .clear
    contentView.addSubview(containerView)
    containerView.addSubview(thumbImageView)
    thumbImageView.addSubview(activityImageLoad)
    containerView.addSubview(titleLabel)
    containerView.addSubview(subTitleLabel)
    containerView.addSubview(timeLabel)
    containerView.addSubview(doteView)
    // make constraints
    containerView.snp.makeConstraints {
      $0.edges.equalToSuperview()
        .inset(UIEdgeInsets(top: 0, left: generalOffset, bottom: 0, right: generalOffset))
    }
    thumbImageView.snp.makeConstraints {
      $0.left.equalToSuperview()
      $0.top.equalToSuperview().offset(generalOffset)
      $0.bottom.equalToSuperview().offset(-generalOffset + dotLineHeight)
    }
    activityImageLoad.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    titleLabel.snp.makeConstraints {
      $0.left.equalTo(thumbImageView.snp.right).offset(generalOffset)
      $0.top.equalToSuperview().offset(topTitleOffset)
      $0.right.equalToSuperview().offset(-generalOffset)
    }
    subTitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(verticalOffset)
      $0.left.right.equalTo(titleLabel)
    }
    timeLabel.snp.makeConstraints {
      $0.top.equalTo(subTitleLabel.snp.bottom).offset(verticalOffset)
      $0.left.right.equalTo(subTitleLabel)
    }
    doteView.snp.makeConstraints {
      $0.left.bottom.right.equalToSuperview()
      $0.height.equalTo(dotLineHeight)
    }
  }

  private func updateUI() {
    guard let viewModel = viewModel, let stream = viewModel.stream else {
      return
    }
    disposeBag = DisposeBag()

    // при каждой перерисовки ячейки - новая картинка - не баг, фитча;)
    // subscribe to get random image
    self.activityImageLoad.startAnimating()
    viewModel.imageObserver.subscribe(
      onNext: { [unowned self] (imageData) in
        if  let imageData = imageData,
            let image = UIImage(data: imageData) {
          DispatchQueue.main.async {
            self.activityImageLoad.stopAnimating()
            self.thumbImageView.image = image
          }
        }
      }).disposed(by: disposeBag)
    titleLabel.text = stream.titleText
    subTitleLabel.text = stream.subTitleText
    timeLabel.text = stream.timeText
  }
}
