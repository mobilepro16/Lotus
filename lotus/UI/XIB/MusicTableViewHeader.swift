//
//  MusicTableViewHeader.swift
//  lotus
//
//  Created by Robert Grube on 10/26/20.
//  Copyright © 2020 Seisan. All rights reserved.
//

import UIKit

protocol MusicTableViewHeaderDelegate {
    func headerTabSelected(dataType: MusicTableData)
    func headerSearchFor(term: String)
}

enum MusicTableData {
    case bookmarks
    case playlists
    case history
    case songs
}

class MusicTableViewHeader: CustomNibView {

    let stackViewHeight : CGFloat = 30
        
    @IBOutlet var searchView: TableHeaderSearchView!
    @IBOutlet var tabStackView: UIStackView!
    
    @IBOutlet var pendingTab: UIButton!   //bookmarks tab
    @IBOutlet var bookmarksTab: UIButton!    //playlists tab
    @IBOutlet weak var historyTab: UIButton!    //history tab
  
    @IBOutlet var constraint_stackView_height: NSLayoutConstraint!
    
    var selectedDataType : MusicTableData = .history
    
    var delegate: MusicTableViewHeaderDelegate?
    
    override func setup() {
        searchView.delegate = self
        updateTabs()
    }
    
    func setTabbar(visible: Bool){
        constraint_stackView_height.constant = visible ? stackViewHeight : 0
        tabStackView.isHidden = !visible
    }

    func updateTabs(){
        if(selectedDataType == .bookmarks){
            pendingTab.setTitleColor(.white, for: .normal)
            bookmarksTab.setTitleColor(.lotusTabUnselected, for: .normal)
            historyTab.setTitleColor(.lotusTabUnselected, for: .normal)
        } else if(selectedDataType == .playlists){
            pendingTab.setTitleColor(.lotusTabUnselected, for: .normal)
            bookmarksTab.setTitleColor(.white, for: .normal)
            historyTab.setTitleColor(.lotusTabUnselected, for: .normal)
        } else {
            pendingTab.setTitleColor(.lotusTabUnselected, for: .normal)
            bookmarksTab.setTitleColor(.lotusTabUnselected, for: .normal)
            historyTab.setTitleColor(.white, for: .normal)
        }
    }
    
  @IBAction func historyTabClick(_ sender: Any) {
        selectedDataType = .history
        delegate?.headerTabSelected(dataType: selectedDataType)
        searchView.searchTextField.resignFirstResponder()
        updateTabs()
  }
  @IBAction func pendingTabClick(_ sender: Any) {
        selectedDataType = .bookmarks
        delegate?.headerTabSelected(dataType: selectedDataType)
        searchView.searchTextField.resignFirstResponder()
        updateTabs()
    }
    
    @IBAction func bookmarkTabClick(_ sender: Any) {
        selectedDataType = .playlists
        delegate?.headerTabSelected(dataType: selectedDataType)
        searchView.searchTextField.resignFirstResponder()
        updateTabs()
    }
}

extension MusicTableViewHeader : TableHeaderSearchViewDelegate {
    func headerSearchFor(term: String) {
        delegate?.headerSearchFor(term: term)
    }
    
    func headerSearchDidBecomeActive() {
        selectedDataType = .songs
        setTabbar(visible: false)
        delegate?.headerTabSelected(dataType: selectedDataType)
    }
    
    func headerCancelButtonClick() {
        setTabbar(visible: true)
        if(pendingTab.titleColor(for: .normal) == .white){
            selectedDataType = .bookmarks
            delegate?.headerTabSelected(dataType: selectedDataType)
        } else if(pendingTab.titleColor(for: .normal) == .white){
            selectedDataType = .playlists
            delegate?.headerTabSelected(dataType: selectedDataType)
        } else {
            selectedDataType = .history
            delegate?.headerTabSelected(dataType: selectedDataType)
        }
    }
}
