//
//  UIView.swift
//  SimpleCoreDataManagerDemo
//
//  Created by Emily Ivie on 2/18/17.
//  Copyright © 2017 urdnot. All rights reserved.
//

import UIKit

extension UIView {
    public func fillView(_ view: UIView!, margin: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor, constant: margin).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin).isActive = true
    }
}
