//
//  GithubSearchViewController.swift
//  FlSwiftExample
//
//  Created by Takuya Osawa on 2020/01/08.
//  Copyright © 2020 Takuya Osawa. All rights reserved.
//

import UIKit
import FlSwift
import RxSwift
import RxCocoa

final class GithubSearchViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Find a Github repository"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        searchBar.rx.text
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { (text) in
                guard let text = text, !text.isEmpty else {
                    return
                }
                NumberActionCreator.shared.fetchRepositories(query: text, page: 1)
            }).disposed(by: disposeBag)
        
        store.state
            .repositories
            .bind(to: tableView.rx.items) { tableView, row, element in
                let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
                cell.textLabel?.text = element
                cell.textLabel?.numberOfLines = 0
                return cell
        }
        .disposed(by: disposeBag)
        
        store.state
            .isLoading
            .asDriver()
            .drive(onNext: { [weak self] (isLoading) in
                self?.activityIndicatorView.isHidden = !isLoading
                if isLoading {
                    self?.activityIndicatorView.startAnimating()
                } else {
                    self?.activityIndicatorView.stopAnimating()
                }
            }).disposed(by: disposeBag)

        tableView.rx.reachedBottom().subscribe(onNext: { [weak self] (_) in
            guard let _self = self else { return }
            if let nextPages = _self.store.state.nextPages {
                NumberActionCreator.shared.fetchRepositories(query: _self.searchBar.text ?? "", page: nextPages)
            }
        }).disposed(by: disposeBag)
        
        tableView.keyboardDismissMode = .onDrag
    }
    
    private var disposeBag = DisposeBag()
    @IBOutlet private weak var tableView: UITableView!
    private lazy var store: Store<NumberState> = {
        let state = NumberState()
        let store = Store(state: state)
        store.subscribe()
        return store
    }()
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
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
