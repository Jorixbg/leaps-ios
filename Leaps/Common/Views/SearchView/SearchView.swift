//
//  SearchView.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/10/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class SearchView: UIView {

    @IBOutlet weak var textView: TextFieldWithImage!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var searchIconWidthConstraint: NSLayoutConstraint!
    var didSelectSearch: (() -> Void)?
    var didSelectBack: (() -> Void)?
    
    var searchEntry: SearchEntry? {
        didSet {
            guard let searcEntry = searchEntry else {
                return
            }
            let distance = "Up to \(String(searcEntry.searchDistance))km"
            let tags = searcEntry.tags.reduce("", { $0 + " • \($1)" } )
            let when = " • \(searcEntry.selectionPeriod.titleForPeriod())"
            textView.text = "\(distance)\(tags)\(when)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    func expand() {
        self.searchIconWidthConstraint.constant = 31
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.layoutIfNeeded()
        }
    }
    
    func collapse(completion: ((Bool) -> Void)?) {
        self.searchIconWidthConstraint.constant = 0
        UIView.animate(withDuration: 0.2, animations: { 
            self.layoutIfNeeded()
        }, completion: completion)
    }
    
    func initialSetup() {
        fromNib()
        let selector = #selector(didTapSearchView)
        let tap = UITapGestureRecognizer(target: self, action: selector)
        self.addGestureRecognizer(tap)
        let resetSelector = #selector(resetSearchTextfield)
        NotificationCenter.default.addObserver(self, selector: resetSelector, name: .resetSearch, object: nil)
        self.textView.layer.cornerRadius = Constants.General.standradCornerRadius
    }
    
    func resetSearchTextfield(notification: Notification) {
        textView.text = ""
    }
    
    //needs to be called explicitly after viewDidLoad as sit is not layout appropriately when loading from nib
    func setTextField(image: UIImage?) {
        textView.set(image: image, enabled: false)
    }
    
    func didTapSearchView() {
        didSelectSearch?()
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        didSelectBack?()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
