//
//  SpecialitiesSelectionTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/20/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class SpecialitiesSelectionTableViewCell: ErrorCreateEventTableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate var addNewSpecialityTag: String = "+"
    fileprivate var additionalTags: [String] = []
    fileprivate var selectedTags: [String] = []
    private var isInitialLoad = true
    
    fileprivate var tags: [String] = [] {
        didSet {
            collectionView.reloadData()
            layoutIfNeeded()
            //Need to reload as on iPhone SE there is an issue whith collection view height on the initial load. This will work as long as we don't need more than one of these cells in a table view.
            guard isInitialLoad else {
                return
            }
            
            onTagAdded?()
            isInitialLoad = false
        }
    }
    
    var onTagSelection: ((String, Bool) -> Void)?
    var onTagAdded: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TagCollectionViewCell.self)
    }
    
    func setTags(tags: [String]) {
        var newTags = tags
        newTags.append(contentsOf: additionalTags)
        newTags.append(addNewSpecialityTag)
        self.tags = newTags
    }
}

extension SpecialitiesSelectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { 
        let cell = collectionView.dequeueReusableCell(of: TagCollectionViewCell.self, for: indexPath) { (cell) in
            let tag = tags[indexPath.row]
            let isAlreadySelected = selectedTags.contains(tag)
            let shouldEnableTap = indexPath.item != tags.count - 1
            cell.setTag(text: tag,
                        color: .leapsOnboardingBlue,
                        shouldEnableTap: shouldEnableTap,
                        selectedTextColor: .white,
                        isAlreadySelected: isAlreadySelected,
                        handleSelection: { [weak self] (tag, selected) in
                
                self?.onTagSelection?(tag, selected)
                            if selected {
                                self?.selectedTags.append(tag)
                            } else {
                                guard let index = self?.selectedTags.index(of: tag) else {
                                    return
                                }
                                self?.selectedTags.remove(at: index)
                            }
            })
        }
        
        return cell
    }
}

extension SpecialitiesSelectionTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == tags.count - 1 {
            
            let alertController = UIAlertController(title: "Custom Tag", message: "Add your custom tag.", preferredStyle: .alert)
            let addAction = UIAlertAction(title: "Add", style: .default, handler: { [weak self] (action) in
                guard let tagTextField = alertController.textFields?[0],
                    let tagName = tagTextField.text,
                    !tagName.isEmpty,
                    self?.tags.contains(tagName) == false else {
                        return
                }
                
                self?.additionalTags.append(tagName)
                self?.onTagAdded?()
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(addAction)
            alertController.addAction(cancelAction)
            alertController.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "tag name"
            })
            
            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        }
    }
}

extension SpecialitiesSelectionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //workaround to get the intrinsic size
        let label = TagLabel()
        label.text = tags[indexPath.row]
        label.layoutIfNeeded()
        let size = label.intrinsicContentSize
        
        return size
    }
}
