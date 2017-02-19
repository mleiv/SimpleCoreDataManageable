//
//  SpinnerNib.swift
//
//  Copyright 2016 Emily Ivie
//  Copied from MEGameTracker

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit

final public class SpinnerNib: UIView {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView?
    @IBOutlet weak var spinnerLabel: UILabel?
    @IBOutlet weak var spacerView: UIView?
    
    var title: String? {
        didSet {
            if oldValue != title {
                setupTitle()
            }
        }
    }
    
    public func setup() {
        setupTitle()
    }
    
    public func setupTitle() {
        spinnerLabel?.text = title
        spinnerLabel?.isHidden = !(title?.isEmpty == false)
        layoutIfNeeded()
    }
    
    public func start() {
        spinner?.startAnimating()
        isHidden = false
    }
    
    public func startSpinning() {
        spinner?.startAnimating()
    }
    
    public func stop() {
        spinner?.stopAnimating()
        isHidden = true
    }
    
    public func changeMessage(_ title: String) {
        spinnerLabel?.text = title
        layoutIfNeeded()
    }
    
    public class func loadNib(title: String? = nil) -> SpinnerNib? {
        let bundle = Bundle(for: SpinnerNib.self)
        if let view = bundle.loadNibNamed("SpinnerNib", owner: self, options: nil)?.first as? SpinnerNib {
            view.title = title
            return view
        }
        return nil
    }
}
