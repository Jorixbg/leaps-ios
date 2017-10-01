//
//  EditProfileViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/23/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    typealias T = ProfileViewModel
    
    @IBOutlet weak var tableView: UITableView!
    
    private let heightAboveKeyboard: CGFloat = 20
    fileprivate weak var delegate: ImageSettable?
    fileprivate var viewModel: ProfileViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        tableView.register(StandradEditProfileTableViewCell.self)
        tableView.register(UserImageTableViewCell.self)
        tableView.register(ImageSelectionTableViewCell.self)
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        setup(navigationController: navigationController)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup(navigationController: UINavigationController?) {
        
        //show navbar
        self.navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        //back button
        let buttonSelector = #selector(didPressCancel)
        let cancelNavButton = UIButton(type: .custom)
        cancelNavButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        cancelNavButton.addTarget(self, action: buttonSelector, for: .touchUpInside)
        cancelNavButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        cancelNavButton.imageEdgeInsets = UIEdgeInsetsMake(0, -11, 0, 0)
        cancelNavButton.tintColor = .leapsOnboardingBlue
        cancelNavButton.contentHorizontalAlignment = .left
        cancelNavButton.contentVerticalAlignment = .center
        let barButton = UIBarButtonItem(customView: cancelNavButton)
        navigationItem.leftBarButtonItem  = barButton
        
        guard let font = UIFont.leapsSFFont(size: 12) else {
            return
        }
        
        //Done Button
        let doneButtonSelector = #selector(didPressDone)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: doneButtonSelector)
        doneButton.setTitleTextAttributes([NSFontAttributeName: font,
                                           NSForegroundColorAttributeName: UIColor.leapsOnboardingBlue], for: .normal)
        self.navigationItem.rightBarButtonItem = doneButton

        //set attributed title
        title = "EDIT PROFILE"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font,
                                                                        NSForegroundColorAttributeName: UIColor.leapsOnboardingBlue]
        
        //remove bottom line
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func didPressDone() {
        viewModel?.updateProfile() { [weak self] error in
            guard error == nil else {
                let alert = UIAlertController(title: "User update error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                return
            }
            
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func didPressCancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height + heightAboveKeyboard, 0)
    }
    func keyboardWillHide(_ notification:Notification) {
        guard let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        tableView.contentInset = .zero
    }
}

extension EditProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfItemsEditProfile(for: section) ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfEditProfileSections ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = viewModel?.editProfileType(forIndexPath: indexPath) else {
            return UITableViewCell()
        }
        
        switch type {
            //shoudl be Image object afterwards
        case .userPicture(let image):
            return tableView.dequeueReusableCell(of: UserImageTableViewCell.self, for: indexPath, configure: { [weak self] (cell) in
                self?.delegate = cell
                print(image?.url)
                cell.setup(imageURLString: image?.url ?? "", onPictureChangePressed: self?.presentPictureSelectionOptions)
                
                cell.onDelteImage = { [weak self] (uplodableImage) in
                    if let image = image {
                        self?.viewModel?.removeImage(currentImageID: image.id, image: uplodableImage)
                    }
                }

                cell.onImageSet = { [weak self] image in
                    self?.viewModel?.addImage(image: image)
                }
            })
        case .trainerPictures(let mainImageURL, let images):
            return tableView.dequeueReusableCell(of: ImageSelectionTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.setup(type: .editProfile, mainImage: mainImageURL, images: images)
                delegate = cell
                
                cell.onImageSelected = { [unowned self] in
                    self.presentPictureSelectionOptions()
                }
                
                cell.onDelteImage = { [unowned self] (id, image) in
                    self.viewModel?.removeImage(currentImageID: id, image: image)
                }
                
                cell.onImageSet = { [unowned self] image in
                    self.viewModel?.addImage(image: image)
                }
            })
        default:
            return editProfileStandardEntryCell(tableView: tableView, indexPath: indexPath, type: type)
        }
    }
    
    func editProfileStandardEntryCell(tableView: UITableView, indexPath: IndexPath, type: EditProfileRowType) -> UITableViewCell {
        let onTextEntered: ((String) -> Void)?
        switch type {
        case .firstName:
            onTextEntered = { [weak self] text in
                self?.viewModel?.userUpdateData?.firstName = text
            }
        case .lastName:
            onTextEntered = { [weak self] text in
                self?.viewModel?.userUpdateData?.lastName = text
            }
        case .username:
            onTextEntered = { [weak self] text in
                self?.viewModel?.userUpdateData?.username = text
            }
        case .gender:
            onTextEntered = { [weak self] text in
                self?.viewModel?.userUpdateData?.gender = text
            }
        case .birthday:
            onTextEntered = { [weak self] text in
                self?.viewModel?.setBirthday(dateAsString: text)
            }
        case .location:
            onTextEntered = { [weak self] text in
                self?.viewModel?.userUpdateData?.location = text
            }
        case .aboutMe:
            onTextEntered = { [weak self] text in
                self?.viewModel?.userUpdateData?.description = text
            }
        case .yearsOfTraining:
            onTextEntered = { [weak self] text in
                self?.viewModel?.setYearsOfTraining(yearsAsString: text)
            }
        case .individualSessionPerHour:
            onTextEntered = { [weak self] text in
                self?.viewModel?.setPricePerSession(priceAsString: text)
            }
        case .phoneNumber:
            onTextEntered = { [weak self] text in
                self?.viewModel?.userUpdateData?.phoneNumber = text
            }
        default:
            onTextEntered = nil
        }
        
        let cell = tableView.dequeueReusableCell(of: StandradEditProfileTableViewCell.self, for: indexPath, configure: { (cell) in
            cell.type = type
            cell.onTextEntered = onTextEntered
        })
        
        return cell
    }
}

extension EditProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension EditProfileViewController: Injectable {
    func inject(_ viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
}

extension EditProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
        let removePhoto = UIAlertAction(title: "Remove image", style: .destructive) { (alert : UIAlertAction!) in
            self.delegate?.unsetImage()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction!) in
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        //optionMenu.addAction(removePhoto)
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
