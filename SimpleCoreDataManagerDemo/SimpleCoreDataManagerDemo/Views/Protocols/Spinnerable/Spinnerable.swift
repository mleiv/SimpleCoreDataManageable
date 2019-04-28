//
//  Spinnerable.swift
//
//  Copyright 2016 Emily Ivie
//  Copied from MEGameTracker

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit

public protocol Spinnerable {
    func startSpinner(inView view: UIView?)
    func startSpinner(inView view: UIView?, title: String?)
    func stopSpinner(inView view: UIView?)
    func stopSpinner(inView view: UIView?, isRemoveFromView: Bool)
    func isSpinning(inView view: UIView?) -> Bool
}

extension Spinnerable {
    internal var isInterfaceBuilder: Bool {
        #if TARGET_INTERFACE_BUILDER
            return true
        #else
            return false
        #endif
    }
    
    public func startSpinner(inView view: UIView?) {
        startSpinner(inView: view, title: nil)
    }
    
    public func startSpinner(inView view: UIView?, title: String?) {
        guard !isInterfaceBuilder else { return }
        let useView = self is UITableViewController ? view?.superview : view
        guard let view = useView,
            let spinner: SpinnerNib = {
                if let spinner = view.subviews.compactMap({ $0 as? SpinnerNib }).first {
                    spinner.title = title
                    return spinner
                } else {
                    if let spinner = SpinnerNib.loadNib(title: title) {
                        view.addSubview(spinner)
                        spinner.fillView(view)
                        return spinner
                    }
                }
                return nil
            }() else { return }
        spinner.start()
    }
    
    public func stopSpinner(inView view: UIView?) {
        stopSpinner(inView: view, isRemoveFromView: false)
    }
    
    /// Some pages throw errors if the spinner remains (tableviews), so allow it to be removed.
    public func stopSpinner(inView view: UIView?, isRemoveFromView: Bool) {
        guard !isInterfaceBuilder else { return }
        let useView = self is UITableViewController ? view?.superview : view
        if let spinner = useView?.subviews.compactMap({ $0 as? SpinnerNib }).first {
            spinner.stop()
            if isRemoveFromView {
                spinner.removeFromSuperview()
            }
        }
    }
    
    public func isSpinning(inView view: UIView?) -> Bool {
        guard !isInterfaceBuilder else { return false }
        let useView = self is UITableViewController ? view?.superview : view
        return useView?.subviews.compactMap({ $0 as? SpinnerNib }).first != nil
    }
}

