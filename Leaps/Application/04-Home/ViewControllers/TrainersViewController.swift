//
//  TrainersViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/21/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class TrainersViewController: UIViewController {
    typealias T = TrainersViewModel
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var viewModel: TrainersViewModel?
    var onSearchPressed: ((SearchEntry) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        tableView.register(TrainerTableViewCell.self)
        tableView.register(TrainersHeaderTableViewCell.self)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.Activities.bottomInset, right: 0)
        viewModel?.traienrs.bind({ [weak self] (trainers) in
            self?.tableView.reloadData()
        })
        viewModel?.fetchTrainers(completion: { (error) in
            print("error = \(String(describing: error))")
        })
        
        onSearchPressed = { [weak self] searchEntry in
            self?.viewModel?.search(searchEntry: searchEntry, isNewSearch: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
}

extension TrainersViewController: Injectable {
    func inject(_ viewModel: TrainersViewModel) {
        self.viewModel = viewModel
    }
}

extension TrainersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.traienrs.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: TrainerTableViewCell.self, for: indexPath) { (cell) in
            guard let trainer = viewModel?.trainer(for: indexPath) else {
                return
            }
            let trainerViewModel = TrainerViewModel(trainer: trainer)
            
            cell.viewModel = trainerViewModel
         }
        
        return cell
    }
}

extension TrainersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let trainer = viewModel?.trainer(for: indexPath) else {
            return
        }
        
        let storyboard = UIStoryboard(name: .common, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createTrainerProfileViewController(trainer: trainer) else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "\(TrainersHeaderTableViewCell.self)") as? TrainersHeaderTableViewCell else {
            return nil
        }
        
        headerCell.numberOfTrainers = viewModel?.traienrs.value.count
        headerCell.type = viewModel?.dataType
        headerCell.selectedHedader = { [unowned self] in
            self.viewModel?.fetchTrainers(completion: { (error) in
                    NotificationCenter.default.post(name: .resetSearch, object: nil)
                })
        }
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.Activities.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

