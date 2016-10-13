//
//  UIViewControllerExtension.swift
//  OnTheMap
//
//  Created by Eduard Meciar on 13/10/2016.
//  Copyright © 2016 Eduard Meciar. All rights reserved.
//
//http://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
