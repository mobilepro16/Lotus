//
//  MessageTableViewHeader.swift
//  lotus
//
//  Created by Robert Grube on 3/10/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol MessageTableViewHeaderDelegate {
    func headerSearchFor(term: String)
    func headerSearchDidBecomeActive()
    func createChannel()
}

enum MessageTableData {
    case message
    case users
}

class MessageTableViewHeader: CustomNibView {

    let stackViewHeight : CGFloat = 30
    
  @IBOutlet weak var headerTitle: UILabel!
  @IBOutlet weak var constraint_stackView_height: NSLayoutConstraint!
  @IBOutlet weak var partiesTab: UIButton!
  @IBOutlet weak var notificationsTab: UIButton!
  @IBOutlet weak var tabStackView: UIStackView!
  @IBOutlet weak var searchView: TableHeaderSearchView!
  @IBOutlet weak var createButton: UIButton!
  
  var selectedDataType : MessageTableData = .message
  var delegate: MessageTableViewHeaderDelegate?
  
  override func setup() {
      searchView.delegate = self
      setTabbar(visible: false)
  }
    
  @IBAction func createTapped(_ sender: Any) {
      delegate?.createChannel()
  }
  func setTabbar(visible: Bool){        
         let vis = false
        
        constraint_stackView_height.constant = vis ? stackViewHeight : 0
        tabStackView.isHidden = !vis
    }
}

extension MessageTableViewHeader : TableHeaderSearchViewDelegate {
    func headerSearchFor(term: String) {
        delegate?.headerSearchFor(term: term)
    }
    func headerSearchDidBecomeActive() {
      
    }
    func headerCancelButtonClick() {
      delegate?.headerSearchDidBecomeActive()
    }
}
