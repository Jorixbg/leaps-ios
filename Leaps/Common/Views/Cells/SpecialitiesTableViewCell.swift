//
//  SpecialitiesTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/26/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class SpecialitiesTableViewCell: UITableViewCell {

    var tags: [String] = [] {
        didSet {
            collectionView.reloadData()
            let height = collectionView.collectionViewLayout.collectionViewContentSize.height
            collectionViewHeightConstraint.constant = height
            layoutIfNeeded()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TagCollectionViewCell.self)
    }
}

extension SpecialitiesTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: TagCollectionViewCell.self, for: indexPath) { [weak self] (tagCell) in
            tagCell.tagLabel.text = self?.tags[indexPath.item]
        }
        
        return cell
    }
}

extension SpecialitiesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //workaround to get the intrinsic size
        let label = TagLabel()
        label.text = tags[indexPath.row]
        label.layoutIfNeeded()
        let size = label.intrinsicContentSize
        
        return size
    }
}



