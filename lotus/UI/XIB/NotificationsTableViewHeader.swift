//
//  NotificationsTableViewHeader.swift
//  lotus
//
//  Created by Robert Grube on 3/10/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol NotificationTableViewHeaderDelegate {
    func headerTabSelected(dataType: NotificationsTableData)
    func headerSearchFor(term: String)
}

enum NotificationsTableData {
    case notifications
    case parties
    case users
}

class NotificationsTableViewHeader: CustomNibView {

    let stackViewHeight : CGFloat = 30
    
  @IBOutlet weak var headerTitle: UILabel!
  @IBOutlet var searchView: TableHeaderSearchView!
    @IBOutlet var tabStackView: UIStackView!
    @IBOutlet var notificationsTab: UIButton!
    @IBOutlet var partiesTab: UIButton!
    
    @IBOutlet var constraint_stackView_height: NSLayoutConstraint!
    
    var selectedDataType : NotificationsTableData = .notifications
    
    var delegate: NotificationTableViewHeaderDelegate?
    
    override func setup() {
        searchView.delegate = self
        updateTabs()
        
        setTabbar(visible: false)
    }
    
    func setTabbar(visible: Bool){
        
         let vis = false
        
        constraint_stackView_height.constant = vis ? stackViewHeight : 0
        tabStackView.isHidden = !vis
    }

    func updateTabs(){
        if(selectedDataType == .notifications){
            notificationsTab.setTitleColor(.white, for: .normal)
            partiesTab.setTitleColor(.lotusTabUnselected, for: .normal)
        } else {
            notificationsTab.setTitleColor(.lotusTabUnselected, for: .normal)
            partiesTab.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBAction func notificationTabClick(_ sender: Any) {
        selectedDataType = .notifications
        delegate?.headerTabSelected(dataType: selectedDataType)
        searchView.searchTextField.resignFirstResponder()
        updateTabs()
    }
    
    @IBAction func partyTabClick(_ sender: Any) {
        selectedDataType = .parties
        delegate?.headerTabSelected(dataType: selectedDataType)
        searchView.searchTextField.resignFirstResponder()
        updateTabs()
    }
}

extension NotificationsTableViewHeader : TableHeaderSearchViewDelegate {
    func headerSearchFor(term: String) {
        delegate?.headerSearchFor(term: term)
    }
    
    func headerSearchDidBecomeActive() {
        selectedDataType = .users
        setTabbar(visible: false)
        delegate?.headerTabSelected(dataType: selectedDataType)
    }
    
    func headerCancelButtonClick() {
        setTabbar(visible: true)
        if(notificationsTab.titleColor(for: .normal) == .white){
            selectedDataType = .notifications
            delegate?.headerTabSelected(dataType: selectedDataType)
        } else {
            selectedDataType = .parties
            delegate?.headerTabSelected(dataType: selectedDataType)
        }
    }
}
