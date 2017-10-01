//
//  UItableView+Dequeue.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/14/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

import UIKit

extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    func register(_ cell: UITableViewCell.Type) {
        let nib = UINib(nibName: "\(cell.self)", bundle: nil)
        register(nib, forCellReuseIdentifier: cell.identifier)
    }
    
    func dequeueReusableCell<CellClass: UITableViewCell>(of class: CellClass.Type,
                             for indexPath: IndexPath,
                             configure: ((CellClass) -> Void) = { _ in }) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: CellClass.identifier, for: indexPath)
        if let typedCell = cell as? CellClass {
            configure(typedCell)
        }
        
        return cell
    }
}
