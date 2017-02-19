//
//  Spinner.swift
//
//  Copyright 2016 Emily Ivie
//  Copied from MEGameTracker

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.


import UIKit

struct Spinner {

    fileprivate var nib: SpinnerNib?
    
    /// - Parameter title: The message for the spinner
    ///
    /// ## Usage Examples: ##
    /// ````
    /// let spinner = Spinner(title: "Test")
    /// spinner.show(from: myView, animated: true) {}
    /// spinner.dismiss(animated: true) {}
    /// ````
    public init(title: String?) {
        nib = SpinnerNib.loadNib(title: title)
    }

    /// Hides the currently displayed spinner.
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        let nib = self.nib
        UIView.animate(withDuration: 1.0, animations: {
            nib?.isHidden = true
        }) {  _ in
            nib?.removeFromSuperview()
            completion?()
        }
    }
    
    /// Displays a spinner in the center of specified view, with grayed out/disabled background.
    ///
    /// Called when you know the UIView to insert into. Otherwise, use presentFromAppropriateController below.
    ///
    /// ## Usage Examples: ##
    /// ````
    /// let spinner = Spinner(title: "Test")
    /// spinner.show(from: myView, animated: true) {}
    /// ````
    public func show(from parentView: UIView, animated: Bool, completion: (() -> Void)?) {
        if let nib = nib {
            if nib.superview == nil {
                parentView.addSubview(nib)
                nib.fillView(parentView)
            }
//            nib.isHidden = true
            parentView.layoutIfNeeded()
            nib.startSpinning()
            UIView.animate(withDuration: 1.0, animations: {
                nib.isHidden = false
            }) { _ in
                completion?()
            }
        }
    }
    
    public func changeMessage(_ title: String) {
        nib?.title = title
    }
}
