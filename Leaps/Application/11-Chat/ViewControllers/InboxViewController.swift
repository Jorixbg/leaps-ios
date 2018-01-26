//
//  InboxViewController.swift
//  Leaps
//
//  Created by Slav Sarafski on 27/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import Firebase

class InboxViewController: UIViewController {

    fileprivate var viewModel: InboxViewModel = InboxViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        setupDefaultNavigationController()
        
        
        
//        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChat))
//        self.navigationItem.rightBarButtonItem = item
        
        tableView.tableFooterView = UIView()
        
        viewModel.chats.bindAndFire { [weak self] (chats) in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.setNavigationBarHidden(true, animated: true)
        
//        self.title = "Inbox".uppercased()
        
        viewModel.loadChats()
    }
}

extension InboxViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        let storyboard = UIStoryboard(name: .chat, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        let chat = self.viewModel.chats.value[indexPath.row]
        guard let vc = factory.createMessangerViewController(chat: chat) else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
