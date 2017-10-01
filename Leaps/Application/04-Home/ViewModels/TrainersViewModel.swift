//
//  TrainersVIewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/21/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

enum TrainerDataType {
    case feed
    case search
}

class TrainersViewModel: BaseViewModel {
    
    let service: UserService
    var traienrs: Dynamic<[User]> = Dynamic([])
    
    fileprivate var isRequestRunning = false
    fileprivate(set) var dataType: TrainerDataType
    fileprivate var searchEntry: SearchEntry?
    
    init(service: UserService, dataType: TrainerDataType = .feed) {
        self.service = service
        self.dataType = dataType
    }
    
    func fetchTrainers(completion: ((Error?) -> Void)?) {
        dataType = .feed
        service.fetchTrainers { [weak self] (result) in
            switch result {
            case .success(let trainers):
                self?.traienrs.value = trainers
                completion?(nil)
            case .error(let error):
                completion?(error)
                print("error fetching trianers = \(error)")
            }
        }
    }
    
    func trainer(for indexPath: IndexPath) -> User? {
        guard indexPath.row < traienrs.value.count else {
            return nil
        }
        
        return traienrs.value[indexPath.row]
    }
}

//search + pagination
extension TrainersViewModel {
    func search(searchEntry: SearchEntry, isNewSearch: Bool) {
        //make sure request is not Running
        guard isRequestRunning == false else {
            return
        }
        
        dataType = .search
        //if it is the firsh search result
        if isNewSearch {
            self.searchEntry = searchEntry
            //for pagination
        } else {
            self.searchEntry?.page += 1
        }
        
        isRequestRunning = true
        
        service.serachTrainers(searchEntry: searchEntry) { [weak self] (result) in
            self?.isRequestRunning = false
            switch result {
            case .success(let trainers):
                if isNewSearch {
                    self?.traienrs.value = trainers
                } else {
                    self?.traienrs.value.append(contentsOf: trainers)
                }
            case .error(let error):
                self?.searchEntry?.page -= 1
                print("error fetching trianers = \(error)")
            }
        }
    }
}
