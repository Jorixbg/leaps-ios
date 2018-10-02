//
//  InboxViewController.swift
//  Leaps
//
//  Created by Slav Sarafski on 27/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import Firebase

class InboxViewController: BasicViewController {

    fileprivate var viewModel: InboxViewModel = InboxViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        viewModel.chats.bindAndFire { [weak self] (chats) in
            if let destination = AppDelegate.notificationDestination
            {
                self?.open(destination: destination)
            }
            self?.tableView.reloadData()
        }
        
        let selector = #selector(onDestinationSet)
        NotificationCenter.default.addObserver(self, selector: selector, name: .notifiacationDestinationSet, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        viewModel.loadChats()
    }
    
    @objc func onDestinationSet(_ notification: NSNotification) {
        if let destination = notification.userInfo?["destination"] as? NotificationDestination
        {
            open(destination: destination)
        }
    }
    
    func open(destination: NotificationDestination) {
        if let chat = viewModel.findChat(by: destination.id)
        {
            navigationController?.popToRootViewController(animated: false)
            open(chat: chat)
            AppDelegate.notificationDestination = nil
        }
    }
    
    func open(chat: Chat) {
        let storyboard = UIStoryboard(name: .chat, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createMessangerViewController(chat: chat) else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension InboxViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.emptyLabel(to: tableView,
                        count: viewModel.chats.value.count,
                        message: "You don't have any chats.")
        
        return viewModel.chats.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(of: ChatTableViewCell.self, for: indexPath) {
            $0.setup(chat: self.viewModel.chats.value[indexPath.row])
        }
    }
}



extension InboxViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = self.viewModel.chats.value[indexPath.row]
        open(chat: chat)
    }
}
