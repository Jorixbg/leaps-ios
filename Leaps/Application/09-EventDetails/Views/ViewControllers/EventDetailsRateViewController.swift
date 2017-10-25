//
//  EventDetailsRateViewController.swift
//  Leaps
//
//  Created by Slav Sarafski on 23/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import Cosmos

class EventDetailsRateViewController: UIViewController {

    
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var imageChooseView: ImageChooseView!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var bottomViewBottomConstrain: NSLayoutConstraint?
    
    fileprivate weak var delegate: ImageSettable?
    fileprivate var viewModel: EventViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextView.delegate = self
        rateButton.isEnabled = false
        
        cosmosView.didFinishTouchingCosmos = {
            rating in
            self.rateButton.isEnabled = rating > 0
        }
        
        imageChooseView.onImagePressed = {
            view in
            self.presentPictureSelectionOptions()
        }
        delegate = self
        
        //Set navigation controller to default look
        setupDefaultNavigationController()
        
        UIApplication.shared.isStatusBarHidden = false
        
        //Aniamte keyboard show/hide
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func rate(_ sender: Any) {
        guard let event = self.viewModel?.event.value else {
            return
        }
        let navController = self.navigationController
        
        self.viewModel?.rateEvent(rating: Int(cosmosView.rating),
                                  comment: commentTextView.text,
                                  completion: { (result) in
                                    switch result{
                                    case .success( _):
                                        self.navigationController?.popViewController(animated: true,
                                                                                     completion: {
                                                                                        
                                                                                        let storyboard = UIStoryboard(name: .common, bundle: nil)
                                                                                        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
                                                                                        guard let vc = factory.createEventDetailsThanksViewController(event: event) else {
                                                                                            return
                                                                                        }
                                                                                        vc.modalPresentationStyle = .overCurrentContext
                                                                                        
                                                                                        navController?.present(vc, animated: false, completion: nil)
                                        })
                                        break
                                    case .error(let error):
                                        print("Rate event with id:\(event.id) was failed \(error)")
                                        break
                                    }
                                    
                                    
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.bottomViewBottomConstrain?.constant = 0.0
            } else {
                self.bottomViewBottomConstrain?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}

extension EventDetailsRateViewController: Injectable {
    func inject(_ viewModel: EventViewModel) {
        self.viewModel = viewModel
    }
}

extension EventDetailsRateViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if commentTextView.text == "Add your comment" {
            commentTextView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentTextView.text == "" {
            commentTextView.text = "Add your comment"
        }
    }
}

extension EventDetailsRateViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
//        let removePhoto = UIAlertAction(title: "Remove image", style: .destructive) { (alert : UIAlertAction!) in
//            self.delegate?.unsetImage()
//        }
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

extension EventDetailsRateViewController: ImageSettable {
    func setImage(image: UIImage) {
        imageChooseView.setImage(image: image)
        
        guard let imageAsData = UIImageJPEGRepresentation(image, Constants.CreateEvent.uploadedPictureCompression) else {
            return
        }
        
        
        let image = UplodableImage(imageData: imageAsData, type: .eventRateImage)
        viewModel?.rateImage = image
    }
    
    func unsetImage() {
        viewModel?.rateImage = nil
    }
}
