//
//  StreamViewController.swift
//  WebPlayer
//
//  Created by Denis Khlopin on 19.06.2020.
//

import UIKit
import RxSwift

private let streamCellReuseIdentifier = "StreamCell"
private let streamCellHeight: CGFloat = 109
private let streamInfoViewHeight = 61
private let generalOffset: CGFloat = 16
private let tableBackgroundColor = UIColor(red: 0.14, green: 0.15, blue: 0.17, alpha: 1.00)
private let titleFont = UIFont.systemFont(ofSize: 15, weight: .bold)

class StreamViewController: UIViewController {
  let viewModel: StreamViewModel!

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero)
    tableView.separatorStyle = .none
    tableView.backgroundColor = tableBackgroundColor
    tableView.register(StreamCell.self, forCellReuseIdentifier: streamCellReuseIdentifier)
    return tableView
  }()

  lazy var streamInfoView: UIView = {
    let view = UIView(frame: .zero)
    view.backgroundColor = .black
    view.snp.makeConstraints {
      $0.height.equalTo(streamInfoViewHeight)
    }
    return view
  }()

  lazy var currentStreamTitle: UILabel = {
    let label = UILabel()
    label.font = titleFont
    label.textColor = .white
    return label
  }()

  private let disposeBag = DisposeBag()

  init(viewModel: StreamViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(tableView)
    view.addSubview(streamInfoView)
    streamInfoView.addSubview(currentStreamTitle)
    tableView.dataSource = self
    tableView.delegate = self
    configureLayout()
  }

  private func configureLayout() {
    streamInfoView.snp.makeConstraints {
      $0.left.top.right.equalToSuperview()
    }
    tableView.snp.makeConstraints {
      $0.top.equalTo(streamInfoView.snp.bottom)
      $0.left.bottom.right.equalToSuperview()
    }
    currentStreamTitle.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalToSuperview().offset(generalOffset)
    }
    subscribeStream()
  }

  private func subscribeStream() {
    viewModel.streamObserver.asObservable().subscribe(
      onNext: { [unowned self](stream) in
        self.currentStreamTitle.text = stream?.titleText
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
}

extension StreamViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.streams.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if  let stream = viewModel.getStream(by: indexPath),
        let cell = tableView.dequeueReusableCell(
            withIdentifier: streamCellReuseIdentifier,
            for: indexPath) as? StreamCell {
      let cellViewModel = StreamCellViewModel(stream: stream)
      cell.viewModel = cellViewModel
      return cell
    }
    return UITableViewCell()
  }

  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    streamCellHeight
  }

}

extension StreamViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel.selectStream(by: indexPath)
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
