//
//  CreateEventStepViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/18/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class CreateEventStepViewController: UIViewController {
    typealias T = CreateEventStepViewModel
    
    @IBOutlet weak var tableView: UITableView!
    
    private let tableViewHardcodedBottomInset: CGFloat = 80
    fileprivate var viewModel: CreateEventStepViewModel?
    
    //thta is done wrong but can't waste time on it now
    var navTitle: String? {
        return viewModel?.title
    }
    
    weak var delegate: ImageSettable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        viewModel?.rows.bind({ (rowtypes) in
            
        })
        
        tableView.register(ImageSelectionTableViewCell.self)
        tableView.register(StandardCreateEventTableViewCell.self)
        tableView.register(TextViewTableViewCell.self)
        tableView.register(SpecialitiesSelectionTableViewCell.self)
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentInset = UIEdgeInsetsMake(0, 0, tableViewHardcodedBottomInset, 0)
        UIApplication.shared.statusBarStyle = .default
    }
}

extension CreateEventStepViewController: Injectable {
    func inject(_ viewModel: CreateEventStepViewModel) {
        self.viewModel = viewModel
    }
}

extension CreateEventStepViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.rows.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = viewModel?.rowType(forIndexPath: indexPath) else {
            return UITableViewCell()
        }
        
        switch type {
        case .imageSelection:
            return tableView.dequeueReusableCell(of: ImageSelectionTableViewCell.self, for: indexPath, configure: { (cell) in
                delegate = cell
                cell.setup(type: .createEvent)
                cell.onImageSelected = { [unowned self] in
                    self.presentPictureSelectionOptions()
                }
                
                cell.onDelteImage = { [unowned self] (id, image) in
                    self.viewModel?.removePicture(currentImageID: id, image: image)
                }
                
                cell.onImageSet = { [unowned self] image in
                    self.viewModel?.addUploadImage(image: image)
                }
            })
        case .description:
            return tableView.dequeueReusableCell(of: TextViewTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.onTextEnter = { [unowned self] text in
                    self.viewModel?.delegate?.enterDescription(description: text)
                }
            })
            
        case .workoutType(let tags):
            return tableView.dequeueReusableCell(of: SpecialitiesSelectionTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.onTagSelection = { [unowned self] tag, isSelected in
                    isSelected
                        ? self.viewModel?.delegate?.addTag(tag: tag)
                        : self.viewModel?.delegate?.removeTag(tag: tag)
                }
                
                cell.onTagAdded = { [unowned self] in
                    self.tableView.reloadData()
                }
                
                cell.setTags(tags: tags)
            })
        case .title, .eventLocation, .priceFrom, .freeSlots, .date, .time:
            return getStandardCell(tableView: tableView, indexPath: indexPath, type: type)
        }
    }
    
    func getStandardCell(tableView: UITableView, indexPath: IndexPath, type: CreateEventRowType) -> UITableViewCell {
        var onTextEnter: ((String) -> Void)? = nil
        
        switch type {
        case .title:
        onTextEnter = { [unowned self] text in
            self.viewModel?.delegate?.enterTitle(title: text)
            }
        case .eventLocation:
            onTextEnter = { [unowned self] text in
                self.viewModel?.delegate?.enterLocation(location: text)
            }
        case .priceFrom:
            onTextEnter = { [unowned self] text in
                self.viewModel?.delegate?.enterPrice(price: text)
            }
        case .freeSlots:
            onTextEnter = { [unowned self] text in
                self.viewModel?.delegate?.enterFreeSlots(slots: text)
            }
        case .date:
            onTextEnter = { [unowned self] text in
                self.viewModel?.delegate?.enterDate(date: text)
            }
        case .time:
            onTextEnter = { [unowned self] text in
                self.viewModel?.delegate?.enterTime(time: text)
            }
        default:
            break
        }
        return tableView.dequeueReusableCell(of: StandardCreateEventTableViewCell.self, for: indexPath, configure: { (cell) in
            cell.setup(type: type)
            cell.onTextEnter = onTextEnter
        })
    }
}

extension CreateEventStepViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension CreateEventStepViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func presentPictureSelectionOptions() {
        let camera = CameraMenager(delegate_: self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionMenu.popoverPresentationController?.sourceView = self.view
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert : UIAlertAction!) in
            camera.getCameraOn(self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert : UIAlertAction!) in
            camera.getPhotoLibraryOn(self, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction!) in
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        UIApplication.topViewController()?.present(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            return
        }
        
        delegate?.setImage(image: image)
        
        picker.dismiss(animated: true, completion: nil)
    }
}
