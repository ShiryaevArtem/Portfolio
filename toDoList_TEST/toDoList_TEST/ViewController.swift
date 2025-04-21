//
//  ViewController.swift
//  toDoList_TEST
//
//  Created by Ширяев Артем on 13.04.2025.
//

import UIKit

class ViewController: UIViewController {
    
    let footerView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        footerView.backgroundColor = .red
        footerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerView)
        NSLayoutConstraint.activate([
            footerView.heightAnchor.constraint(equalToConstant: 84),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

