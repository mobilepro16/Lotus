//
//  TableHeaderSearchView.swift
//  lotus
//
//  Created by Robert Grube on 3/6/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol TableHeaderSearchViewDelegate {
    func headerSearchFor(term: String)
    func headerSearchDidBecomeActive()
    func headerCancelButtonClick()
}

class TableHeaderSearchView: CustomNibView, UITextViewDelegate {
    
    @IBOutlet var searchTextFieldView: UIView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet var constraint_cancelButtonWidth: NSLayoutConstraint!
    
    var delegate : TableHeaderSearchViewDelegate?

    override func setup() {
        searchTextFieldView.layer.cornerRadius = 16
        searchTextField.delegate = self
        searchTextField.leftViewMode = .always 
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        let image = UIImage(named: "search")
        imageView.image = image
        searchTextField.leftView = imageView
        constraint_cancelButtonWidth.isActive = false
        searchTextField.attributedPlaceholder = NSAttributedString(string:searchTextField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    @IBAction func cancelButtonClick(_ sender: Any) {
        delegate?.headerCancelButtonClick()
        clearButton.isHidden = true
        searchTextField.text = nil
        searchTextField.resignFirstResponder()
    }
    
    @IBAction func clearTextClick(_ sender: Any) {
        searchTextField.text = nil
    }
}

extension TableHeaderSearchView : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        clearButton.isHidden = false
        delegate?.headerSearchDidBecomeActive()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        clearButton.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let txt = textField.text {
            textField.resignFirstResponder()
            delegate?.headerSearchFor(term: txt)
        }
        
        return true
    }
}

