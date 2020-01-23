//
//  InterfaceController.swift
//  FlSwiftExample_Watch Extension
//
//  Created by Takuya Osawa on 2019/12/02.
//  Copyright © 2019 Takuya Osawa. All rights reserved.
//

import WatchKit
import Foundation
import FlSwift
import RxSwift
import RxCocoa

class InterfaceController: WKInterfaceController {
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        label.setText("rx")
        
        store.state
            .repositories
            .subscribe(onNext: { [weak self] (array) in
                self?.reloadTable(array: array)
            }).disposed(by: disposeBag)
        
        NumberActionCreator.shared.fetchRepositories(query: "rx", page: 1)
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    private func reloadTable(array: [String]) {
        guard !array.isEmpty else {
            return
        }
        
        table.setNumberOfRows(array.count, withRowType: "default")
        array.enumerated().forEach { (offset, element) in
            DispatchQueue.main.async {
                if let row = self.table.rowController(at: offset) as? Cell {
                    row.titleLabel.setText(element)
                }
            }
        }
    }
    
    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet weak var label: WKInterfaceLabel!
    private var disposeBag = DisposeBag()
    lazy var store: Store<NumberState> = {
        let state = NumberState()
        let store = Store(state: state)
        store.subscribe()
        return store
    }()
}

final class Cell: NSObject {
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
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
