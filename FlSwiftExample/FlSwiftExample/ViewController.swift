//
//  ViewController.swift
//  FlSwiftExample
//
//  Created by Takuya Osawa on 2019/11/15.
//  Copyright © 2019 Takuya Osawa. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func flswiftButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "GithubSearchViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        navigationController?.pushViewController(vc, animated: true)
    }
}

