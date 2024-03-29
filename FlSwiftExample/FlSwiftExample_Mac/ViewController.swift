//
//  ViewController.swift
//  FlSwiftExample_Mac
//
//  Created by Takuya Osawa on 2019/11/28.
//  Copyright © 2019 Takuya Osawa. All rights reserved.
//

import Cocoa
import FlSwift
import RxSwift
import RxCocoa

final class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Find a Github repository"
        
        searchField.rx.text
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { (text) in
                guard let text = text, !text.isEmpty else {
                    return
                }
                NumberActionCreator.shared.fetchRepositories(query: text, page: 1)
            }).disposed(by: disposeBag)
        
        
        store.state
            .repositories
            .asDriver()
            .drive(onNext: { [weak self] (items) in
                self?.items = items
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        reachedBottom
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in () }
            .subscribe(onNext: { [weak self] (_) in
                guard let _self = self else { return }
                if let nextPages = _self.store.state.nextPages {
                    NumberActionCreator.shared.fetchRepositories(query: _self.searchField.stringValue, page: nextPages)
                }
            }).disposed(by: disposeBag)
        
        store.state
            .isLoading
            .asDriver()
            .drive(onNext: { [weak self] (isLoading) in
                self?.progressIndicator.isHidden = !isLoading
                if isLoading {
                    self?.progressIndicator.startAnimation(nil)
                } else {
                    self?.progressIndicator.stopAnimation(nil)
                }
            }).disposed(by: disposeBag)
        
        if let clipView = tableView.superview, let sv = clipView.superview as? NSScrollView {
            let contentView = sv.contentView
            contentView.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(tableViewDidScroll(_:)),
                                                   name: NSView.boundsDidChangeNotification,
                                                   object: clipView)
        }
    }
    
    @objc private func tableViewDidScroll(_ notifiacton: Notification) {
        guard let clipView = tableView.superview, let sv = clipView.superview as? NSScrollView else {
            return
        }
        
        let visibleHeight = tableView.frame.height
        let y = sv.documentVisibleRect.origin.y
        let size = sv.documentView?.frame.size ?? .zero
        let threshold = max(0,  size.height - visibleHeight)
        
        reachedBottom.onNext(y >= threshold)
    }
    
    @IBOutlet private weak var tableView: NSTableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    private let disposeBag = DisposeBag()
    private var reachedBottom = PublishSubject<Bool>()
    @IBOutlet weak var searchField: NSSearchField!
    private lazy var store: Store<NumberState> = {
        let state = NumberState()
        let store = Store(state: state)
        store.subscribe()
        return store
    }()
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    private var items: [String] = []
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MyView"), owner: self) as? NSTableCellView
        cell?.textField?.stringValue = items[row]
        return cell
    }
    
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
}


enum NumberAction: Action {
    case responseRepositories([String], Int, Int?)
    case error(Error)
    case isLoading(Bool)
}

class NumberActionCreator {
    static let shared = NumberActionCreator()
    private init() {}
    let dispatcher = FlSwift.Dispatcher<NumberAction>.shared
    
    func fetchRepositories(query: String, page: Int) {
        dispatcher.dispatch(.isLoading(true))
        var urlComponents = URLComponents(string: "https://api.github.com/search/repositories")!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: page.description)
        ]
        
        let request = URLRequest(url: urlComponents.url!)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            self?.dispatcher.dispatch(.isLoading(false))
            if let error = error {
                self?.dispatcher.dispatch(.error(error))
                return
            }
            
            guard let data = data, let response = response else {
                return
            }
            
            do {
                guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    return
                }
                /// https://github.com/tryswift/RxPagination/blob/master/Pagination/PaginationRequest.swift
                let elements = dictionary["items"] as? [[String: Any]]
                
                var _nextPage: Int?
                if let urlResponse = response as? HTTPURLResponse {
                    let nextURI = urlResponse.findLink(relation: "next")?.uri
                    let queryItems = nextURI.flatMap(URLComponents.init)?.queryItems
                    _nextPage = queryItems?
                        .filter { $0.name == "page" }
                        .compactMap { $0.value }
                        .compactMap { Int($0) }
                        .first
                }
                var full_names: [String] = []
                elements?.forEach({ (dic) in
                    if let full_name = dic["full_name"] as? String {
                        full_names.append(full_name)
                    }
                })
                self?.dispatcher.dispatch(.responseRepositories(full_names, page, _nextPage))
            } catch {
                self?.dispatcher.dispatch(.error(error))
            }
        }
        
        task.resume()
    }
}

class NumberState: State {
    typealias ActionType = NumberAction
    
    func reduce(action: NumberAction) {
        switch action {
        case .error(let _error):
            error.onNext(_error)
        case .responseRepositories(let _repositories, let _page, let _nextPages):
            if _page == 1 {
                repositories.accept(_repositories)
            } else {
                repositories.accept(repositories.value + _repositories)
            }
            
            page = _page
            nextPages = _nextPages
        case .isLoading(let _isLoading):
            isLoading.accept(_isLoading)
        }
    }
    
    var page = 1
    var nextPages: Int?
    var repositories = BehaviorRelay<[String]>(value: [])
    var error = PublishSubject<Error>()
    var isLoading = BehaviorRelay<Bool>(value: false)
}
