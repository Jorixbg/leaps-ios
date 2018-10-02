//
//  MessangerViewController.swift
//  Leaps
//
//  Created by Slav Sarafski on 2/12/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import ReverseExtension

class MessangerViewController: UIViewController {

    fileprivate var viewModel: MessangerViewModel = MessangerViewModel(chat: nil)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var outgoingView: UIView!
    @IBOutlet weak var outgoingTextField: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet var inputBottomLayoutConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        setupDefaultNavigationController()
        
        tableView.register(ChatMessageTableViewCell.self)
        tableView.register(ChatDateTableViewCell.self)
        tableView.register(ChatSeenTableViewCell.self)
        tableView.estimatedRowHeight = 48
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.re.delegate = self
        
        sendButton.layer.borderColor = UIColor.leapsOnboardingBlue.cgColor
        sendButton.layer.borderWidth = 1
        sendButton.layer.cornerRadius = 6
        
        viewModel.messages.bindAndFire { [weak self] (chats) in
            self?.tableView.reloadData()
        }
        
        viewModel.chat.bindAndFire { chat in
            self.titleLabel.text = self.viewModel.chat.value?.other.name.uppercased()
        }
        
        viewModel.loadMessages()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: .UIKeyboardWillChangeFrame,
                                               object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        AppDelegate.openedChatID = viewModel.chat.value?.key
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //viewModel.seenMessage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.openedChatID = nil
    }
    
    @IBAction func sendMessage() {
        if outgoingTextField.text != "" {
            viewModel.send(message: outgoingTextField.text)
            outgoingTextField.text = ""
            //dismissKeyboard()
        }
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                inputBottomLayoutConstraint?.constant = 0.0
                //tableView.contentOffset = CGPoint(x: 0, y: outgoingView.frame.minY)
            } else {
                inputBottomLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
                //tableView.contentOffset = CGPoint(x: 0, y: endFrame!.minY)
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    @IBAction func back() {
        navigationController?.popViewController(animated: true)
    }
}

extension MessangerViewController: KeyboardDismissible {
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension MessangerViewController: Injectable {
    func inject(_ viewModel: MessangerViewModel) {
        self.viewModel = viewModel
    }
}

extension MessangerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let message = self.viewModel.messages.value[indexPath.row] as? ChatMessage {
            // ChatMessageTableViewCell - Bubble cell
            return tableView.dequeueReusableCell(of: ChatMessageTableViewCell.self, for: indexPath) {
                if let user = self.viewModel.chat.value?.user(for: message.sender) {
                    $0.setup(message: message, user: user)
                }
            }
        }
        else if let data = self.viewModel.messages.value[indexPath.row] as? MessangerDate {
            // ChatDateTableViewCell - Date cell
            return tableView.dequeueReusableCell(of: ChatDateTableViewCell.self, for: indexPath) {
                $0.setup(data: data)
            }
        }
        else {
            // ChatSeenTableViewCell - Seen cell
            return tableView.dequeueReusableCell(of: ChatSeenTableViewCell.self, for: indexPath) {_ in
                
            }
        }
    }
}

extension MessangerViewController: UITableViewDelegate {

}
