//
//  DynamicCollectionView.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/22/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class DynamicCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !bounds.size.equalTo(intrinsicContentSize) {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let intrinsicContentSize: CGSize = contentSize
        return intrinsicContentSize
    }
}
