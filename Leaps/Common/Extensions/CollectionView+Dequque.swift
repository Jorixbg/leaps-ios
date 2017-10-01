//
//  CollectionView+Dequque.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/26/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    func register(_ cell: UICollectionViewCell.Type) {
        let nib = UINib(nibName: "\(cell.self)", bundle: nil)
        register(nib, forCellWithReuseIdentifier: cell.identifier)
    }
    
    func dequeueReusableCell<CellClass: UICollectionViewCell>(of class: CellClass.Type,
                             for indexPath: IndexPath,
                             configure: ((CellClass) -> Void) = { _ in }) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: CellClass.identifier, for: indexPath)
        if let typedCell = cell as? CellClass {
            configure(typedCell)
        }
        
        return cell
    }
}

extension UICollectionReusableView {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {
    func register(_ reusableViewClass: UICollectionReusableView.Type, forSupplementaryViewOfKind kind: String) {
        let nib = UINib(nibName: "\(reusableViewClass.self)", bundle: nil)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: reusableViewClass.identifier)
    }
    
    func dequeueReusableSupplementaryView<ReusableViewClass: UICollectionReusableView>(of class: ReusableViewClass.Type,
                                          kind: String,
                                          for indexPath: IndexPath,
                                          configure: ((ReusableViewClass) -> Void) = { _ in }) -> UICollectionReusableView {
        let reusableView = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ReusableViewClass.identifier, for: indexPath)
        if let typedView = reusableView as? ReusableViewClass {
            configure(typedView)
        }
        
        return reusableView
    }
}
